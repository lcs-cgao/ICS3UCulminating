import Foundation

/// Represents a single game that was completed.
struct GameRecord: Identifiable {
    let id = UUID()
    let winner: Player? // nil means draw
    let mode: String    // "VS AI" or "PVP"
    let moveCount: Int
    let date = Date()
}
