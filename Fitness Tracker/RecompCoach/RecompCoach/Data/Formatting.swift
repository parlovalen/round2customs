//
//  Formatting.swift
//  RecompCoach
//
//  Small parsing/formatting helpers for turning text-field strings into optional
//  numeric values and back.
//

import Foundation

extension String {
    /// Trimmed Int, or nil if blank/invalid.
    var optInt: Int? {
        let t = trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? nil : Int(t)
    }
    /// Trimmed Double, or nil if blank/invalid.
    var optDouble: Double? {
        let t = trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? nil : Double(t)
    }
}

extension Optional where Wrapped == Int {
    /// Field string for an optional Int ("" when nil).
    var fieldText: String { map(String.init) ?? "" }
}

extension Optional where Wrapped == Double {
    var fieldText: String {
        guard let v = self else { return "" }
        // Trim trailing ".0" for whole numbers.
        return v == v.rounded() ? String(Int(v)) : String(v)
    }
}

/// Compact "1.0" -> "1", "1.5" -> "1.5" formatting for display.
func trimDecimal(_ v: Double) -> String {
    v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
}
