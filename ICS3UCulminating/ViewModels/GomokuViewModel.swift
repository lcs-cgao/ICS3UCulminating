import Foundation
import Observation

import Foundation
import Observation

@Observable
class GomokuViewModel {
    
    // MARK: - Stored properties
    
    /// The core game engine (The Model). 
    /// This is private because the View should never talk to the Model directly.
    /// It must go through this ViewModel.
    private var game: GomokuGame
    
    // MARK: - Computed properties
    
    /// The 15x15 board that the View will draw.
    /// It is a copy of the Model's board.
    var board: [[Player?]] {
        return game.board
    }
    
    /// The player whose turn it is right now.
    var currentPlayer: Player {
        return game.currentPlayer
    }
    
    /// Returns true if someone has won or if it is a draw.
    var isGameOver: Bool {
        if game.gameState == .playing {
            return false
        } else {
            return true
        }
    }
    
    /// Returns true if the game is in VS AI mode.
    var isVsAI: Bool {
        return game.isVsAI
    }
    
    /// A human-readable message showing the game status.
    /// Examples: "Black's Turn", "White Wins!", "It's a Draw!"
    var statusMessage: String {
        let state = game.gameState
        
        switch state {
        case .playing:
            let name = game.currentPlayer.rawValue
            if isVsAI && game.currentPlayer == .white {
                return "AI is thinking..."
            }
            return "\(name)'s Turn"
            
        case .won(let winner):
            let name = winner.rawValue
            return "\(name) Wins!"
            
        case .draw:
            return "The board is full. It's a draw!"
        }
    }
    
    /// If there is a winner, this returns their name. 
    /// If not, it returns an empty string.
    var winnerName: String {
        let state = game.gameState
        
        switch state {
        case .won(let winner):
            return winner.rawValue
        default:
            return ""
        }
    }
    
    // MARK: - Initializer
    
    /// Creates a new ViewModel and starts a fresh game model.
    init() {
        self.game = GomokuGame()
    }
    
    // MARK: - Functions
    
    /// This is the primary function the View calls when a user taps the grid.
    /// - Parameters:
    ///   - row: The vertical position (0 to 14)
    ///   - col: The horizontal position (0 to 14)
    func placeStone(atRow row: Int, andColumn col: Int) {
        // We ask the Model to try and place the stone.
        // The Model handles all the rules (is it empty? is the game over?).
        let success = game.placeStone(row: row, col: col)
        
        // If it's the AI's turn and the move was successful, trigger the AI move
        if success && isVsAI && game.gameState == .playing && game.currentPlayer == .white {
            // Small delay to make it feel more natural
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.game.makeAIMove()
            }
        }
    }
    
    /// Toggles the VS AI mode and resets the game.
    func toggleAIMode() {
        game.isVsAI = !game.isVsAI
        game.resetGame()
    }
    
    /// Resets the entire game back to the starting state (Empty 15x15 board, Black starts).
    func startNewGame() {
        game.resetGame()
    }
}


