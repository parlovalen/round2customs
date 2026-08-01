//
//  SupplementCatalog.swift
//  RecompCoach
//
//  Authored list of the recommended supplements from Reference/plan/
//  supplements_guide.md. Only evidence-backed, honestly-labeled options — food
//  and training do almost all the work; these are small edges, not shortcuts.
//

import SwiftUI

/// How strongly a supplement is recommended (drives the row's badge colour).
enum SupplementTag: String {
    case recommended = "Recommended"
    case optional = "Optional"
    case conditional = "Get tested first"

    var color: Color {
        switch self {
        case .recommended: return Theme.moss
        case .optional: return Theme.chalkDim
        case .conditional: return Color(hex: 0xE0A22E)
        }
    }
}

/// An authored supplement recommendation (immutable reference content).
struct SupplementDef: Identifiable, Hashable {
    let id: String
    let name: String
    let dose: String
    let timing: String
    let tag: SupplementTag
    let icon: String
}

enum SupplementCatalog {
    /// The daily-relevant shortlist, in priority order.
    static let recommended: [SupplementDef] = [
        SupplementDef(
            id: "creatine", name: "Creatine Monohydrate",
            dose: "3–5 g", timing: "Any time, daily",
            tag: .recommended, icon: "bolt.fill"
        ),
        SupplementDef(
            id: "whey", name: "Whey Protein",
            dose: "20–40 g", timing: "To help hit 185 g protein",
            tag: .recommended, icon: "cup.and.saucer.fill"
        ),
        SupplementDef(
            id: "electrolytes", name: "Electrolytes",
            dose: "Per serving", timing: "Around soccer / heavy sweat",
            tag: .recommended, icon: "bolt.horizontal.fill"
        ),
        SupplementDef(
            id: "vitd", name: "Vitamin D",
            dose: "1,000–2,000 IU", timing: "With a fatty meal",
            tag: .conditional, icon: "sun.max.fill"
        ),
        SupplementDef(
            id: "omega3", name: "Fish Oil (Omega-3)",
            dose: "1–2 g EPA+DHA", timing: "With meals",
            tag: .optional, icon: "pills.fill"
        )
    ]
}
