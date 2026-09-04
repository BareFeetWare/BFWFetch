//
//  DateFormatting.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 2/9/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// Reads a date from a string written in one fixed form.
///
/// Foundation splits that job across two unrelated classes: `DateFormatter`, whose meaning comes from a locale and calendar, and `ISO8601DateFormatter`, whose grammar is fixed and immune to a device's settings. Neither descends from the other and they share no date-reading type, so an array of forms to try in turn cannot hold both without this. Both already declare exactly this method, so each conformance is empty.
public protocol DateFormatting {
    func date(from string: String) -> Date?
}

// MARK: - Protocol Conformances

extension DateFormatter: DateFormatting {}

extension ISO8601DateFormatter: DateFormatting {}
