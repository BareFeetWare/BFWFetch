#  BFWFetch
Simple and Robust API Calls, using the Fetchable protocol

## Introduction

The `Fetchable` protocol provides a simple and flexible way to fetch data from API calls.

Read more detail about Fetchable in the [Better Programming publication on Medium](https://medium.com/p/4ddf8710d1a0/).

A `Fetchable` type must provide:

1. A `baseURL`
2. The fetch parameter keys as an `enum Key: FetchKey`.
3. The `Fetched` type expected in the response.

Fetchable takes care of all the inner workings. Fetchable provides a Combine publisher, which we can observe to update our model and UI.

## Example: Open Weather

According to the [Open Weather API docs](https://openweathermap.org/current), to fetch weather data for a city, we need to provide:

1. Base URL: https://api.openweathermap.org/data/2.5
2. End URL path: weather
3. Parameter keys: `appID`, `q` (the site's city and country code) , `units`.

The API will respond with a JSON payload containing a `Site`.

For example, we might call the API with these values for each parameter key:

- `appID` = `1234567890abcdef`
- `q` = `Sydney, AU` (for Sydney, Australia)
- `units` = `metric`

Open Weather will provide you with your own appID, after you [sign up](https://home.openweathermap.org/users.sign_up). It's free.

## Fetchable Request

In order to fetch the weather, with the example request above, we can simply create a Weather type that conforms to Fetchable, like this:

```Swift
import BFWFetch

struct Weather: Fetchable {
    
    static let baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    
    enum Key: String, FetchKey {
        case appID
        case site = "q"
        case system = "units"
    }
    
    typealias Fetched = Site
    
}
```

That's it!

Fetchable takes care of mapping the keys to request parameters, creating the URL, request and network connection.

## Fetching

To initiate the actual fetch from the API, we just ask our Fetchable type for a publisher:

```Swift
Weather.publisher(
    keyValues: [
        .appID: "1234567890abcdef",
        .site: "Sydney,AU",
        .system: .metric
    ]
)
```

Since the keys are cases of an enum, the compiler forces us to enter the keys correctly, and lists them in the code completion popup menu (when we type the leading period).

## Custom Function

We would typically expose the keys as parameters in a custom Swift function, such as:

```Swift
import Combine

extension Weather {
    static func publisher(
        city: String,
        countryCode: String?,
        system: System
    ) {
        publisher(
            keyValues: [
                .appID: "1234567890abcdef",
                .site: [city, countryCode]
                    .compactMap { $0 }
                    .joined(separator: ","),
                .system: system
            ]
        )
    }
}
```

Let's  define our units system as `enum System`, and let `Fetchable` know that it conforms to `FetchValue`, so we can use it in the `keyValues` dictionary, as shown above.

```Swift
/// Measurement system, such as metric, imperial.
enum System {
    case metric
    case imperial
}

extension System: FetchValue {}
```

We would call that function from our view model, such as:

```Swift
extension WeatherScene {
    class ViewModel: ObservableObject {
        @Published var city: String = ""
        @Published var countryCode: String = ""
        @Published var system: System = .metric
        @Published var site: Site?
        private var subscribers = Set<AnyCancellable>()
    }
}

extension WeatherScene.ViewModel {
    func fetch() {
        Weather.publisher(
            city: city,
            countryCode: countryCode,
            system: system
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { self.site = $0 }
        )
        .store(in: &subscribers)
    }
}
```
