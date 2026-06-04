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
    
    let boardSize: Int = 15
    var board: [[Player?]]
    var currentPlayer: Player = .black
    var gameState: GameState = .playing
    var lastMove: (row: Int, col: Int)?
    
    // MARK: - Initializer
    
    init() {
        // Initialize a 15x15 board filled with nil (empty)
        var initialBoard: [[Player?]] = []
        for _ in 0..<boardSize {
            var row: [Player?] = []
            for _ in 0..<boardSize {
                row.append(nil)
            }
            initialBoard.append(row)
        }
        self.board = initialBoard
    }
    
    // MARK: - Functions
    
    /// Attempts to place a stone at the specified coordinate.
    /// - Parameters:
    ///   - row: The row index (0-14)
    ///   - col: The column index (0-14)
    /// - Returns: Bool indicating if the move was successful
    func placeStone(row: Int, col: Int) -> Bool {
        // 1. Validation: Is the game still active?
        if gameState != .playing {
            return false
        }
        
        // 2. Validation: Is the move within bounds?
        if row < 0 || row >= boardSize || col < 0 || col >= boardSize {
            return false
        }
        
        // 3. Validation: Is the cell empty?
        if board[row][col] != nil {
            return false
        }
        
        // 4. Update the board
        board[row][col] = currentPlayer
        lastMove = (row, col)
        
        // 5. Check for win or draw
        if checkWin(at: row, col: col) {
            gameState = .won(currentPlayer)
        } else if isBoardFull() {
            gameState = .draw
        } else {
            // 6. Switch players if game continues
            currentPlayer = currentPlayer.opponent()
        }
        
        return true
    }
    
    /// Resets the game to the initial state.
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
    
    // MARK: - Private Logic
    
    private func checkWin(at row: Int, col: Int) -> Bool {
        let player = board[row][col]
        
        // Directions: (row delta, col delta)
        let directions: [(dr: Int, dc: Int)] = [
            (0, 1),  // Horizontal
            (1, 0),  // Vertical
            (1, 1),  // Diagonal (top-left to bottom-right)
            (1, -1)  // Diagonal (top-right to bottom-left)
        ]
        
        for dir in directions {
            var count = 1 // Count the stone just placed
            
            // Search in positive direction
            count += countConsecutive(row: row, col: col, dr: dir.dr, dc: dir.dc, player: player)
            
            // Search in negative direction
            count += countConsecutive(row: row, col: col, dr: -dir.dr, dc: -dir.dc, player: player)
            
            // Freestyle rule: 5 or more in a row wins
            if count >= 5 {
                return true
            }
        }
        
        return false
    }
    
    private func countConsecutive(row: Int, col: Int, dr: Int, dc: Int, player: Player?) -> Int {
        var count = 0
        var currentRow = row + dr
        var currentCol = col + dc
        
        while currentRow >= 0 && currentRow < boardSize && currentCol >= 0 && currentCol < boardSize {
            if board[currentRow][currentCol] == player {
                count += 1
                currentRow += dr
                currentCol += dc
            } else {
                break
            }
        }
        
        return count
    }
    
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
