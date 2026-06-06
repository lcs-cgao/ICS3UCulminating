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

/// Represents a single game that was completed.
struct GameRecord: Identifiable {
    let id = UUID()
    let winner: Player? // nil means draw
    let mode: String    // "VS AI" or "PVP"
    let moveCount: Int
    let date = Date()
}

@Observable
class GomokuGame {
    
    // MARK: - Stored properties
    
    /// The size of the grid (15x15).
    let boardSize: Int = 15
    
    /// The 2D array representing the board. 
    var board: [[Player?]]
    
    /// Tracks whose turn it is.
    var currentPlayer: Player = .black
    
    /// Tracks the current state of the game.
    var gameState: GameState = .playing
    
    /// A list of moves in order. This allows us to show move numbers (1, 2, 3...).
    var moveHistory: [(row: Int, col: Int)] = []
    
    /// A list of completed games saved during this session.
    var gameSessionHistory: [GameRecord] = []
    
    /// If true, the game is played against the computer (AI).
    var isVsAI: Bool = false
    
    /// The color the human player is playing.
    var userPlayerColor: Player = .black
    
    /// If true, the players are currently "guessing" which stone is which color.
    var isSideSelectionActive: Bool = true
    
    /// The actual colors hidden behind the two "mystery" stones.
    private var hiddenSides: [Player] = [.black, .white]
    
    // MARK: - Initializer
    
    init() {
        var initialBoard: [[Player?]] = []
        for _ in 0..<boardSize {
            var row: [Player?] = []
            for _ in 0..<boardSize {
                row.append(nil)
            }
            initialBoard.append(row)
        }
        self.board = initialBoard
        prepareForSideSelection()
    }
    
    // MARK: - Functions
    
    /// Returns the move number for a specific cell (returns 0 if empty).
    func getMoveNumber(row: Int, col: Int) -> Int {
        for (index, move) in moveHistory.enumerated() {
            if move.row == row && move.col == col {
                return index + 1
            }
        }
        return 0
    }
    
    /// Prepares the game for the "Guessing Phase".
    func prepareForSideSelection() {
        isSideSelectionActive = true
        hiddenSides = [.black, .white].shuffled()
    }
    
    /// Called when a user "guesses" a stone.
    func selectSide(at index: Int) {
        if index < 0 || index >= hiddenSides.count {
            return
        }
        userPlayerColor = hiddenSides[index]
        isSideSelectionActive = false
        resetBoard()
    }
    
    /// Just clears the board without changing sides.
    private func resetBoard() {
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
        self.moveHistory = []
    }
    
    /// Resets everything and starts the side selection phase again.
    func resetGame() {
        prepareForSideSelection()
    }
    
    /// The main logic for making a move.
    func placeStone(row: Int, col: Int) -> Bool {
        if gameState != .playing || isSideSelectionActive {
            return false
        }
        
        if row < 0 || row >= boardSize || col < 0 || col >= boardSize {
            return false
        }
        
        if board[row][col] != nil {
            return false
        }
        
        // --- ACTION PHASE ---
        board[row][col] = currentPlayer
        moveHistory.append((row, col))
        
        // --- CHECK PHASE ---
        if checkWin(at: row, col: col) {
            gameState = .won(currentPlayer)
            saveGameToHistory(winner: currentPlayer)
        } else if isBoardFull() {
            gameState = .draw
            saveGameToHistory(winner: nil)
        } else {
            currentPlayer = currentPlayer.opponent()
        }
        
        return true
    }
    
    /// Saves the current game result to the session history.
    private func saveGameToHistory(winner: Player?) {
        let record = GameRecord(
            winner: winner,
            mode: isVsAI ? "VS AI" : "PVP",
            moveCount: moveHistory.count
        )
        gameSessionHistory.insert(record, at: 0) // Add to the top of the list
    }
    
    /// Makes a move for the AI.
    func makeAIMove() {
        let aiColor = userPlayerColor.opponent()
        
        if gameState != .playing || currentPlayer != aiColor || isSideSelectionActive {
            return
        }
        
        // --- AI STRATEGY ---
        if let last = moveHistory.last {
            for r in (last.row - 1)...(last.row + 1) {
                for c in (last.col - 1)...(last.col + 1) {
                    if r >= 0 && r < boardSize && c >= 0 && c < boardSize {
                        if board[r][c] == nil {
                            _ = placeStone(row: r, col: c)
                            return
                        }
                    }
                }
            }
        }
        
        let center = boardSize / 2
        if board[center][center] == nil {
            _ = placeStone(row: center, col: center)
            return
        }
        
        for distance in 1..<boardSize {
            for r in (center - distance)...(center + distance) {
                for c in (center - distance)...(center + distance) {
                    if r >= 0 && r < boardSize && c >= 0 && c < boardSize {
                        if board[r][c] == nil {
                            _ = placeStone(row: r, col: c)
                            return
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private Logic
    
    private func checkWin(at row: Int, col: Int) -> Bool {
        let player = board[row][col]
        let directions: [(dr: Int, dc: Int)] = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for dir in directions {
            var count = 1 
            count += countConsecutive(row: row, col: col, dr: dir.dr, dc: dir.dc, player: player)
            count += countConsecutive(row: row, col: col, dr: -dir.dr, dc: -dir.dc, player: player)
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
