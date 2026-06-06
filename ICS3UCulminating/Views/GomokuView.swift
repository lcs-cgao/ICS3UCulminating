import SwiftUI

struct GomokuView: View {
    
    // MARK: - Stored properties
    
    @State private var viewModel = GomokuViewModel()
    @State private var showingHistory = false
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 15) {
            // --- Header Section ---
            headerSection
            
            // --- Game Area Section ---
            ZStack {
                boardLayer
                    .blur(radius: viewModel.isSelectingSide ? 8 : 0)
                    .disabled(viewModel.isSelectingSide)
                
                if viewModel.isSelectingSide {
                    selectionOverlay
                }
            }
            .padding(10)
            
            // --- Footer Section ---
            footerLayer
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingHistory) {
            historySheet
        }
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
    
    // MARK: - Sub-Views
    
    private var headerSection: some View {
        VStack(spacing: 5) {
            Text("Gomoku")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(viewModel.statusMessage)
                .font(.title2)
                .foregroundColor(viewModel.isGameOver ? .red : .primary)
                .multilineTextAlignment(.center)
            
            if !viewModel.isSelectingSide {
                Text("You are playing as \(viewModel.userColor.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var boardLayer: some View {
        GeometryReader { geometry in
            let boardWidth = geometry.size.width
            let cellSize = boardWidth / CGFloat(15)
            
            ZStack {
                // Background
                Color(red: 0.85, green: 0.70, blue: 0.45)
                    .cornerRadius(8)
                
                // Grid Lines
                drawGrid(cellSize: cellSize, boardWidth: boardWidth)
                
                // Stones with Move Numbers
                drawStones(cellSize: cellSize)
            }
            .frame(width: boardWidth, height: boardWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var selectionOverlay: some View {
        VStack(spacing: 30) {
            Text("Pick a stone to see your side!")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            
            HStack(spacing: 50) {
                ForEach(0..<2) { index in
                    Button(action: {
                        withAnimation {
                            viewModel.selectSide(at: index)
                        }
                    }) {
                        Circle()
                            .fill(Color.gray)
                            .overlay(
                                Text("?")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            )
                            .frame(width: 80, height: 80)
                            .shadow(radius: 5)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
    
    private var footerLayer: some View {
        VStack(spacing: 12) {
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.startNewGame()
                }) {
                    Text("New Game")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showingHistory = true
                }) {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            
            Button(action: {
                viewModel.toggleAIMode()
            }) {
                Text(viewModel.isVsAI ? "Switch to PVP Mode" : "Switch to VS AI")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isVsAI ? Color.purple : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private var historySheet: some View {
        NavigationView {
            List(viewModel.history) { record in
                HStack {
                    VStack(alignment: .leading) {
                        Text(record.winner == nil ? "Draw" : "\(record.winner!.rawValue) Won")
                            .fontWeight(.bold)
                        Text(record.mode)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(record.moveCount) moves")
                        Text(record.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Recent Games")
            .toolbar {
                Button("Done") {
                    showingHistory = false
                }
            }
        }
    }
    
    // MARK: - Functions (Drawing)
    
    func drawGrid(cellSize: CGFloat, boardWidth: CGFloat) -> some View {
        ZStack {
            ForEach(0..<15, id: \.self) { i in
                // Vertical lines
                Path { path in
                    let x = CGFloat(i) * cellSize + (cellSize / 2)
                    path.move(to: CGPoint(x: x, y: cellSize / 2))
                    path.addLine(to: CGPoint(x: x, y: boardWidth - (cellSize / 2)))
                }
                .stroke(Color.black, lineWidth: 1)
                
                // Horizontal lines
                Path { path in
                    let y = CGFloat(i) * cellSize + (cellSize / 2)
                    path.move(to: CGPoint(x: cellSize / 2, y: y))
                    path.addLine(to: CGPoint(x: boardWidth - (cellSize / 2), y: y))
                }
                .stroke(Color.black, lineWidth: 1)
            }
        }
    }
    
    func drawStones(cellSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<15, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<15, id: \.self) { col in
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.placeStone(atRow: row, andColumn: col)
                                }
                            
                            if let player = viewModel.board[row][col] {
                                let moveNum = viewModel.moveNumber(atRow: row, andColumn: col)
                                
                                Circle()
                                    .fill(player == .black ? Color.black : Color.white)
                                    .shadow(radius: 2)
                                    .padding(2)
                                
                                // Display move number on the stone
                                Text("\(moveNum)")
                                    .font(.system(size: cellSize * 0.4))
                                    .fontWeight(.bold)
                                    .foregroundColor(player == .black ? .white : .black)
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
