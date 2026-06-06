import Foundation
import Observation

@Observable
class GomokuViewModel {
    
    // MARK: - Stored properties
    
    /// The core game engine (The Model). 
    private var game: GomokuGame
    
    // MARK: - Computed properties
    
    /// The 15x15 board that the View will draw.
    var board: [[Player?]] {
        return game.board
    }
    
    /// The list of completed games in the current session.
    var history: [GameRecord] {
        return game.gameSessionHistory
    }
    
    /// The player whose turn it is right now.
    var currentPlayer: Player {
        return game.currentPlayer
    }
    
    /// Returns true if the players are currently picking their colors.
    var isSelectingSide: Bool {
        return game.isSideSelectionActive
    }
    
    /// Returns true if the game is over.
    var isGameOver: Bool {
        if game.gameState == .playing || isSelectingSide {
            return false
        } else {
            return true
        }
    }
    
    /// Returns true if the game is in VS AI mode.
    var isVsAI: Bool {
        return game.isVsAI
    }
    
    /// The color assigned to the user.
    var userColor: Player {
        return game.userPlayerColor
    }
    
    /// A human-readable message showing the game status.
    var statusMessage: String {
        if isSelectingSide {
            return "Guess a stone to pick your color!"
        }
        
        let state = game.gameState
        switch state {
        case .playing:
            let name = game.currentPlayer.rawValue
            if isVsAI && game.currentPlayer != userColor {
                return "AI is thinking..."
            }
            return "\(name)'s Turn"
            
        case .won(let winner):
            return "\(winner.rawValue) Wins!"
            
        case .draw:
            return "The board is full. It's a draw!"
        }
    }
    
    // MARK: - Initializer
    
    init() {
        self.game = GomokuGame()
    }
    
    // MARK: - Functions (Logic for the View)
    
    /// Returns the move number for a specific cell.
    func moveNumber(atRow row: Int, andColumn col: Int) -> Int {
        return game.getMoveNumber(row: row, col: col)
    }
    
    /// Called when the user taps one of the two mystery stones.
    func selectSide(at index: Int) {
        game.selectSide(at: index)
        triggerAIMoveIfNecessary()
    }
    
    /// Taps the grid to place a stone.
    func placeStone(atRow row: Int, andColumn col: Int) {
        if isSelectingSide || (isVsAI && game.currentPlayer != userColor) {
            return
        }
        
        let success = game.placeStone(row: row, col: col)
        
        if success && isVsAI && game.gameState == .playing {
            triggerAIMoveIfNecessary()
        }
    }
    
    /// Toggles the VS AI mode and starts a new selection phase.
    func toggleAIMode() {
        game.isVsAI = !game.isVsAI
        startNewGame()
    }
    
    /// Resets the game back to the side selection phase.
    func startNewGame() {
        game.resetGame()
    }
    
    /// Helper to trigger the AI if it is its turn.
    private func triggerAIMoveIfNecessary() {
        if isVsAI && game.gameState == .playing && game.currentPlayer != userColor {
            // Delay to simulate "thinking"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.game.makeAIMove()
            }
        }
    }
}
