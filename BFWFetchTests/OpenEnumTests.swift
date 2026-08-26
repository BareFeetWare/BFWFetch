//
//  OpenEnumTests.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 26/8/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Testing
import Foundation
@testable import BFWFetch

@Suite("OpenEnum Tests")
struct OpenEnumTests {
    
    enum Engine: String, Sendable {
        case luxand = "Luxand"
        case faceNet = "FaceNet"
    }
    
    struct Row: Decodable {
        let id: String
        let engine: OpenEnum<Engine>?
    }
    
    // MARK: - Decoding
    
    @Test("A value the Known type declares decodes as known")
    func knownValueDecodes() throws {
        let row = try JSONDecoder().decode(Row.self, from: Data(#"{"id": "a", "engine": "Luxand"}"#.utf8))
        #expect(row.engine == .known(.luxand))
    }
    
    @Test("A value the Known type does not declare is kept rather than refused")
    func unknownValueIsKept() throws {
        let row = try JSONDecoder().decode(Row.self, from: Data(#"{"id": "a", "engine": "SomethingNewer"}"#.utf8))
        #expect(row.engine == .unknown("SomethingNewer"))
    }
    
    @Test("A value sent as a number is kept as its digits")
    func numberIsKeptAsDigits() throws {
        let row = try JSONDecoder().decode(Row.self, from: Data(#"{"id": "a", "engine": 8}"#.utf8))
        #expect(row.engine == .unknown("8"))
    }
    
    @Test("An absent value stays absent")
    func absentValueStaysAbsent() throws {
        let row = try JSONDecoder().decode(Row.self, from: Data(#"{"id": "a"}"#.utf8))
        #expect(row.engine == nil)
    }
    
    /// The reason the number case matters: a single element that refuses to decode discards every element returned with it.
    @Test("A number in one element leaves the rest of the array decodable")
    func aNumberCostsOnlyItsOwnElement() throws {
        let json = Data("""
            [
                {"id": "a", "engine": "Luxand"},
                {"id": "b", "engine": 8},
                {"id": "c", "engine": "FaceNet"}
            ]
            """.utf8)
        let rows = try JSONDecoder().decode([Row].self, from: json)
        #expect(rows.map(\.id) == ["a", "b", "c"])
        #expect(rows.map(\.engine) == [.known(.luxand), .unknown("8"), .known(.faceNet)])
    }
    
    // MARK: - Encoding
    
    @Test("A known value encodes as its raw value")
    func knownValueEncodes() throws {
        let data = try JSONEncoder().encode(OpenEnum<Engine>.known(.luxand))
        #expect(String(decoding: data, as: UTF8.self) == #""Luxand""#)
    }
    
    @Test("An unknown value encodes as what arrived")
    func unknownValueEncodes() throws {
        let data = try JSONEncoder().encode(OpenEnum<Engine>.unknown("SomethingNewer"))
        #expect(String(decoding: data, as: UTF8.self) == #""SomethingNewer""#)
    }
    
    // MARK: - RawRepresentable
    
    @Test("A raw value round trips through both cases")
    func rawValueRoundTrips() {
        #expect(OpenEnum<Engine>(rawValue: "Luxand") == .known(.luxand))
        #expect(OpenEnum<Engine>(rawValue: "SomethingNewer") == .unknown("SomethingNewer"))
        #expect(OpenEnum<Engine>.known(.luxand).rawValue == "Luxand")
        #expect(OpenEnum<Engine>.unknown("SomethingNewer").rawValue == "SomethingNewer")
    }
    
}
