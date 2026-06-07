import Foundation

/// Represents the two players in the game.
enum Player: String {
    case black = "Black"
    case white = "White"
    
    /// Returns the opposite player.
    func opponent() -> Player {
        if self == .black {
            return .white
        } else {
            return .black
        }
    }
}
