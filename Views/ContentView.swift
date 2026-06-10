import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GraphViewModel()
    @State private var showNodeForm = false
    @State private var csvInput = ""
    @State private var showCSVInput = true
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Control Bar
                HStack {
                    Text("Total Edge Length: \(String(format: "%.2f", viewModel.totalEdgeLength))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text("Critical Path: \(viewModel.criticalPathLength) nodes")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Button(action: { showNodeForm.toggle() }) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                    
                    Button(action: { showCSVInput.toggle() }) {
                        Image(systemName: "doc.text")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
                .padding(12)
                .background(.gray.opacity(0.1))
                
                // Canvas
                GraphCanvasView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Overlay forms
            if showCSVInput {
                CSVInputView(isPresented: $showCSVInput, viewModel: viewModel)
            }
            
            if showNodeForm {
                NodeFormView(isPresented: $showNodeForm, viewModel: viewModel)
            }
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        let sampleCSV = """
        Node1,,Value1_1,Value2_1
        Node2,Node1,Value1_2,Value2_2
        Node3,Node1,Value1_3,Value2_3
        Node4,Node2,Value1_4,Value2_4
        Node5,Node3,Value1_5,Value2_5
        """
        viewModel.loadCSV(sampleCSV)
    }
}

#Preview {
    ContentView()
}
