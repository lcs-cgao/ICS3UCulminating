import Foundation

/// Represents the current stage of the game.
enum GameState: Equatable {
    case playing
    case won(Player)
    case draw
}
