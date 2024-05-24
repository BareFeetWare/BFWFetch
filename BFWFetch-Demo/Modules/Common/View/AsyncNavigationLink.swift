//
//  AsyncNavigationLink.swift
//
//  Created by Tom Brodhurst-Hill on 1/2/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

// Extracted from BFWViews: https://bitbucket.org/barefeetware/bfwviews/

import SwiftUI

/**
 Facilitates:
 1. The cell shows a `>` disclosure indicator.
 2. The user taps anywhere on the label/row.
 3. The cell indicator changes to a ProgressView.
 4. The app performs the destination(), such as fetching from an API.
 5. When the destination completes, the indicator changes back to a disclosure indicator.
 6. The app moves forward to the destination scene.
 7. No error handling yet.
 */
public struct AsyncNavigationLink<Destination: View, Label: View, Tag: Hashable> {
    let tag: Tag
    let externalSelectionBinding: Binding<Tag?>?
    /// Used internally if no external selection binding is provided.
    @State private var internalSelection: Tag?
    /// Only changes when activeDestination is ready.
    @State private var activeSelection: Tag?
    let destination: () async throws -> Destination
    let label: () -> Label
    @State private var isInProgress = false
    @State private var activeDestination: Destination?
    @State private var error: Error?
    
    public init(
        tag: Tag,
        selection: Binding<Tag?>? = nil,
        destination: @escaping () async throws -> Destination,
        label: @escaping () -> Label
    ) {
        self.tag = tag
        self.externalSelectionBinding = selection
        self.destination = destination
        self.label = label
    }
    
}

extension AsyncNavigationLink {
    
    public init(
        _ title: String,
        tag: Tag,
        selection: Binding<Tag?>? = nil,
        destination: @escaping () async throws -> Destination
    ) where Label == Text {
        self.tag = tag
        self.externalSelectionBinding = selection
        self.destination = destination
        self.label = { Text(title) }
    }
    
}

extension AsyncNavigationLink where Label == Text, Tag == String {
    
    public init(
        _ title: String,
        destination: @escaping () async throws -> Destination
    ) {
        self.tag = UUID().uuidString
        self.externalSelectionBinding = nil
        self.destination = destination
        self.label = { Text(title) }
    }
    
    public init(
        destination: @escaping () async throws -> Destination,
        label: @escaping () -> Label
    ) {
        self.tag = UUID().uuidString
        self.externalSelectionBinding = nil
        self.destination = destination
        self.label = label
    }
    
}

private extension AsyncNavigationLink {
    
    /// Used by the view
    var selectionBinding: Binding<Tag?> {
        .init {
            externalSelectionBinding?.wrappedValue ?? internalSelection
        } set: { newValue in
            if externalSelectionBinding != nil {
                externalSelectionBinding?.wrappedValue = newValue
            } else {
                internalSelection = newValue
            }
        }
    }
    
    var selection: Tag? {
        get { selectionBinding.wrappedValue }
        set { selectionBinding.wrappedValue = newValue }
    }
    
    func activateDestination() {
        DispatchQueue.main.async {
            isInProgress = true
            Task {
                do {
                    activeDestination = try await destination()
                    if selectionBinding.wrappedValue != tag {
                        selectionBinding.wrappedValue = tag
                    }
                    activeSelection = tag
                    isInProgress = false
                } catch {
                    self.error = error
                }
            }
        }
    }
    
    func activateDestinationIfNeeded() {
        if selection == tag && activeSelection != tag {
            activateDestination()
        }
    }
    
    func onTap() {
        activateDestination()
    }
    
    func onChange(selection: Tag?) {
        activateDestinationIfNeeded()
    }
    
    func onAppear() {
        activateDestinationIfNeeded()
    }
    
}

extension AsyncNavigationLink: View {
    public var body: some View {
        NavigationLink(tag: tag, selection: $activeSelection) {
            activeDestination
        } label: {
            labelView
        }
    }
    
    var labelView: some View {
        label()
            .frame(maxWidth: .infinity, alignment: .leading)
        // Note: .contentShape(Rectangle()) is required to extend the tappable area across the whole cell width.
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
            .onChange(of: selection) { onChange(selection: $0) }
            .overlay(
                Group {
                    if isInProgress {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                },
                alignment: .trailing
            )
            .onAppear { onAppear() }
            .alert(error: $error)
    }
}

public struct AsyncNavigationLink_Previews: PreviewProvider {
    
    public struct Preview: View {
        
        public init() {}
        
        @State var selection: String?
        
        public var body: some View {
            List {
                Section {
                    AsyncNavigationLink(
                        tag: "1",
                        selection: $selection,
                        destination: {
                            try await asyncDestination(
                                title: "Async Destination 1"
                            )
                        },
                        label: { Text("Async 1") }
                    )
                    AsyncNavigationLink(
                        tag: "2",
                        selection: $selection,
                        destination: {
                            try await asyncDestination(
                                title: "Async Destination 2"
                            )
                        },
                        label: { Text("Async 2") }
                    )
                    AsyncNavigationLink("Async 3") {
                        try await asyncDestination(
                            title: "Async Destination 3"
                        )
                    }
                }
                Section {
                    Button("Activate 1") {
                        selection = "1"
                    }
                    Button("Activate 2") {
                        selection = "2"
                    }
                }
            }
            .navigationTitle("AsyncNavigationLink")
        }
        
        /// Dummy asyc destination, delayed by a timer. Typically this would instead be an async API call.
        func asyncDestination(title: String) async throws -> some View {
            // Arbitrary delay, pretending to be an async request.
            try await Task.sleep(nanoseconds: 2000000000)
            return Text(title)
        }
    }
    
    public static var previews: some View {
        NavigationView {
            Preview()
        }
    }
}
