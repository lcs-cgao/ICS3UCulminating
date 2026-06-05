import SwiftUI

struct GomokuView: View {
    
    // MARK: - Stored properties
    
    /// The ViewModel that controls the game state.
    /// Since it uses the @Observable macro, the View updates automatically.
    @State private var viewModel = GomokuViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 20) {
            // --- Header Section ---
            Text("Gomoku")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(viewModel.statusMessage)
                .font(.title2)
                .foregroundColor(viewModel.isGameOver ? .red : .primary)
            
            // --- Game Board Section ---
            // We use a GeometryReader to make sure the board is a perfect square
            GeometryReader { geometry in
                let boardWidth = geometry.size.width
                let cellSize = boardWidth / CGFloat(15) // 15 intersections
                
                ZStack {
                    // 1. The wooden-style background
                    Color(red: 0.85, green: 0.70, blue: 0.45)
                        .cornerRadius(8)
                    
                    // 2. The Grid Lines
                    drawGrid(cellSize: cellSize, boardWidth: boardWidth)
                    
                    // 3. The Stones (Invisible buttons for tapping + the visible stones)
                    drawStones(cellSize: cellSize)
                }
                .frame(width: boardWidth, height: boardWidth)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(10)
            
            // --- Footer Section ---
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.startNewGame()
                }) {
                    Text("Reset Game")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.toggleAIMode()
                }) {
                    Text(viewModel.isVsAI ? "PVP Mode" : "VS AI")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isVsAI ? Color.purple : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        // Shows an alert when the game is over
        .alert("Game Over", isPresented: Binding(
            get: { viewModel.isGameOver },
            set: { _ in }
        )) {
            Button("New Game") {
                viewModel.startNewGame()
            }
        } message: {
            Text(viewModel.statusMessage)
        }
    }
    
    // MARK: - Functions (Sub-Views)
    
    /// Draws the horizontal and vertical lines of the 15x15 board.
    func drawGrid(cellSize: CGFloat, boardWidth: CGFloat) -> some View {
        ZStack {
            // Vertical Lines
            ForEach(0..<15, id: \.self) { i in
                Path { path in
                    let x = CGFloat(i) * cellSize + (cellSize / 2)
                    path.move(to: CGPoint(x: x, y: cellSize / 2))
                    path.addLine(to: CGPoint(x: x, y: boardWidth - (cellSize / 2)))
                }
                .stroke(Color.black, lineWidth: 1)
            }
            
            // Horizontal Lines
            ForEach(0..<15, id: \.self) { i in
                Path { path in
                    let y = CGFloat(i) * cellSize + (cellSize / 2)
                    path.move(to: CGPoint(x: cellSize / 2, y: y))
                    path.addLine(to: CGPoint(x: boardWidth - (cellSize / 2), y: y))
                }
                .stroke(Color.black, lineWidth: 1)
            }
        }
    }
    
    /// Handles the drawing of placed stones and the tap detection logic.
    func drawStones(cellSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<15, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<15, id: \.self) { col in
                        ZStack {
                            // The tappable area (an empty square)
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.placeStone(atRow: row, andColumn: col)
                                }
                            
                            // The stone itself (only visible if the spot isn't nil)
                            if let player = viewModel.board[row][col] {
                                Circle()
                                    .fill(player == .black ? Color.black : Color.white)
                                    .shadow(radius: 2)
                                    .padding(2)
                            }
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}

#Preview {
    GomokuView()
}
