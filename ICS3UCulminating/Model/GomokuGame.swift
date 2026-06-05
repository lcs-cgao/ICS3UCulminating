import Foundation
import Observation

// MARK: - Enums

enum Player: String {
    case black = "Black"
    case white = "White"
    
    func opponent() -> Player {
        if self == .black {
            return .white
        } else {
            return .black
        }
    }
}

enum GameState: Equatable {
    case playing
    case won(Player)
    case draw
}

@Observable
class GomokuGame {
    
    // MARK: - Stored properties
    
    /// The size of the grid (15x15). Using a smaller board makes games faster.
    let boardSize: Int = 15
    
    /// The 2D array representing the board. 
    /// 'nil' means the intersection is empty.
    /// 'Player' means a stone is placed there.
    var board: [[Player?]]
    
    /// Tracks whose turn it is. Black always starts in Gomoku.
    var currentPlayer: Player = .black
    
    /// Tracks the current state of the game (playing, won, or draw).
    var gameState: GameState = .playing
    
    /// Stores the last move made, which helps in efficient win checking.
    var lastMove: (row: Int, col: Int)?
    
    // MARK: - Initializer
    
    init() {
        // We create the board by nested loops.
        // This is like drawing 15 rows, and in each row, drawing 15 empty spots.
        var initialBoard: [[Player?]] = []
        for _ in 0..<boardSize {
            var row: [Player?] = []
            for _ in 0..<boardSize {
                row.append(nil) // Start with all spots empty
            }
            initialBoard.append(row)
        }
        self.board = initialBoard
    }
    
    // MARK: - Functions
    
    /// The main logic for making a move.
    /// It validates the move, updates the board, and checks if someone won.
    func placeStone(row: Int, col: Int) -> Bool {
        // Safety Check 1: Don't allow moves if the game is already over.
        if gameState != .playing {
            return false
        }
        
        // Safety Check 2: Ensure the click was actually inside the 15x15 grid.
        if row < 0 || row >= boardSize || col < 0 || col >= boardSize {
            return false
        }
        
        // Safety Check 3: Only allow placing a stone on an empty (nil) spot.
        if board[row][col] != nil {
            return false
        }
        
        // --- ACTION PHASE ---
        // Place the current player's stone on the board.
        board[row][col] = currentPlayer
        lastMove = (row, col)
        
        // --- CHECK PHASE ---
        // After placing a stone, we check if this move won the game.
        if checkWin(at: row, col: col) {
            gameState = .won(currentPlayer)
        } else if isBoardFull() {
            // If no one won but the board is full, it's a draw.
            gameState = .draw
        } else {
            // If the game continues, swap to the other player.
            currentPlayer = currentPlayer.opponent()
        }
        
        return true
    }
    
    /// Resets everything to start a brand new game.
    func resetGame() {
        var newBoard: [[Player?]] = []
        for _ in 0..<boardSize {
            var row: [Player?] = []
            for _ in 0..<boardSize {
                row.append(nil)
            }
            newBoard.append(row)
        }
        self.board = newBoard
        self.currentPlayer = .black
        self.gameState = .playing
        self.lastMove = nil
    }
    
    // MARK: - Private Logic (The "Brain" of the game)
    
    /// This function checks 4 axes around the stone just placed:
    /// Horizontal, Vertical, and the two Diagonals.
    private func checkWin(at row: Int, col: Int) -> Bool {
        let player = board[row][col]
        
        // These numbers represent the 'steps' we take to move in a direction.
        // e.g., (0, 1) means stay in the same row, move 1 column right.
        let directions: [(dr: Int, dc: Int)] = [
            (0, 1),  // Horizontal axis
            (1, 0),  // Vertical axis
            (1, 1),  // Diagonal axis (\)
            (1, -1)  // Anti-diagonal axis (/)
        ]
        
        for dir in directions {
            // We start with 1 (the stone we just placed).
            var count = 1 
            
            // Look forward in this direction (e.g., look Right)
            count += countConsecutive(row: row, col: col, dr: dir.dr, dc: dir.dc, player: player)
            
            // Look backward in this direction (e.g., look Left)
            count += countConsecutive(row: row, col: col, dr: -dir.dr, dc: -dir.dc, player: player)
            
            // If we found 5 or more in a row on this axis, we have a winner!
            if count >= 5 {
                return true
            }
        }
        
        return false
    }
    
    /// A helper that 'walks' in a specific direction as long as it sees the same color stone.
    private func countConsecutive(row: Int, col: Int, dr: Int, dc: Int, player: Player?) -> Int {
        var count = 0
        var currentRow = row + dr
        var currentCol = col + dc
        
        // Keep walking as long as we are inside the board.
        while currentRow >= 0 && currentRow < boardSize && currentCol >= 0 && currentCol < boardSize {
            // If the stone at this spot matches our player, increment count.
            if board[currentRow][currentCol] == player {
                count += 1
                // Move to the next spot in the same direction.
                currentRow += dr
                currentCol += dc
            } else {
                // If we see an empty spot or an opponent's stone, stop walking.
                break
            }
        }
        
        return count
    }
    
    /// Simple check to see if there are any empty (nil) spots left.
    private func isBoardFull() -> Bool {
        for row in board {
            for cell in row {
                if cell == nil {
                    return false
                }
            }
        }
        return true
    }
}
