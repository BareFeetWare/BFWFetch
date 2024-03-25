//
//  Plan.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 22/3/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

// Extracted from BFWViews: https://bitbucket.org/barefeetware/bfwviews/

import SwiftUI

/// View model for SwiftUI List, Section, Cell (row).
enum Plan {
    
    struct List {
        let sections: [Section]
    }
    
    struct Section: Identifiable {
        let id: String
        let title: String?
        let cells: [Cell]
        
        init(
            id: String = UUID().uuidString,
            title: String?, cells: [Cell]
        ) {
            self.id = id
            self.title = title
            self.cells = cells
        }
    }
    
    struct Cell: Identifiable {
        let id: String
        let content: () -> any View
        
        init<Content: View>(
            id: String = UUID().uuidString,
            content: @escaping () -> Content
        ) {
            self.id = id
            self.content = content
        }
        
        init<Content>(
            content: @escaping () -> Content
        ) where Content: View & Identifiable, Content.ID == String {
            self.id = content().id
            self.content = content
        }
    }
    
}

// MARK: - View

extension Plan.List: View {
    var body: some View {
        List {
            ForEach(sections) { $0 }
        }
    }
}

extension Plan.Section: View {
    var body: some View {
        Section {
            ForEach(cells) { $0 }
        } header: {
            title.map { Text($0) }
        }
    }
}

extension Plan.Cell: View {
    var body: some View {
        AnyView(content())
    }
}
