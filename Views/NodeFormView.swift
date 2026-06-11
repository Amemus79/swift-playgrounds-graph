import SwiftUI

struct NodeFormView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: GraphViewModel
    @State private var childId = ""
    @State private var parentId = ""
    @State private var value1 = ""
    @State private var value2 = ""
    @State private var showSuccess = false
    @State private var isPaused = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            #if os(macOS)
            VStack(spacing: 12) {
                Text("Add Node")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Child ID:")
                            .frame(width: 100, alignment: .leading)
                        TextField("e.g., Node1", text: $childId)
                            .disabled(isPaused)
                    }
                    
                    HStack {
                        Text("Parent ID:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Leave empty for root", text: $parentId)
                            .disabled(isPaused)
                    }
                    
                    HStack {
                        Text("Value 1:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Display value 1", text: $value1)
                            .disabled(isPaused)
                    }
                    
                    HStack {
                        Text("Value 2:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Display value 2", text: $value2)
                            .disabled(isPaused)
                    }
                }
                .font(.caption)
                
                if showSuccess {
                    VStack(spacing: 4) {
                        Text("✓ Node added successfully!")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .fontWeight(.semibold)
                        
                        if isPaused {
                            Text("Paused - Graph recalculating...")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        resetForm()
                        isPresented = false
                    }
                    .foregroundStyle(.red)
                    .disabled(isPaused)
                    
                    Spacer()
                    
                    if isPaused {
                        Button("Continue") {
                            resetForm()
                            isPaused = false
                            showSuccess = false
                        }
                        .foregroundStyle(.blue)
                    } else {
                        Button("Add Node") {
                            viewModel.addNode(
                                childId: childId,
                                parentId: parentId.isEmpty ? nil : parentId,
                                value1: value1,
                                value2: value2
                            )
                            
                            showSuccess = true
                            isPaused = true
                            
                            // Pause for 2 seconds before allowing next action
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isPaused = false
                            }
                        }
                        .foregroundStyle(.blue)
                        .disabled(childId.isEmpty)
                    }
                }
            }
            .padding(16)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
            .padding(16)
            .frame(minWidth: 400, minHeight: 300)
            #else
            VStack(spacing: 12) {
                Text("Add Node")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Child ID:")
                            .frame(width: 80, alignment: .leading)
                        TextField("e.g., Node1", text: $childId)
                            .textFieldStyle(.roundedBorder)
                            .disabled(isPaused)
                    }
                    
                    HStack {
                        Text("Parent ID:")
                            .frame(width: 80, alignment: .leading)
                        TextField("Leave empty for root", text: $parentId)
                            .textFieldStyle(.roundedBorder)
                            .disabled(isPaused)
                    }
                    
                    HStack {
                        Text("Value 1:")
                            .frame(width: 80, alignment: .leading)
                        TextField("Display value 1", text: $value1)
                            .textFieldStyle(.roundedBorder)
                            .disabled(isPaused)
                    }
                    
                    HStack {
                        Text("Value 2:")
                            .frame(width: 80, alignment: .leading)
                        TextField("Display value 2", text: $value2)
                            .textFieldStyle(.roundedBorder)
                            .disabled(isPaused)
                    }
                }
                .font(.caption)
                
                if showSuccess {
                    VStack(spacing: 4) {
                        Text("✓ Node added successfully!")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .fontWeight(.semibold)
                        
                        if isPaused {
                            Text("Paused - Graph recalculating...")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        resetForm()
                        isPresented = false
                    }
                    .foregroundStyle(.red)
                    .disabled(isPaused)
                    
                    Spacer()
                    
                    if isPaused {
                        Button("Continue") {
                            resetForm()
                            isPaused = false
                            showSuccess = false
                        }
                        .foregroundStyle(.blue)
                    } else {
                        Button("Add Node") {
                            viewModel.addNode(
                                childId: childId,
                                parentId: parentId.isEmpty ? nil : parentId,
                                value1: value1,
                                value2: value2
                            )
                            
                            showSuccess = true
                            isPaused = true
                            
                            // Pause for 2 seconds before allowing next action
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isPaused = false
                            }
                        }
                        .foregroundStyle(.blue)
                        .disabled(childId.isEmpty)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
            #endif
        }
    }
    
    private func resetForm() {
        childId = ""
        parentId = ""
        value1 = ""
        value2 = ""
        showSuccess = false
        isPaused = false
    }
}

#Preview {
    @State var presented = true
    return NodeFormView(isPresented: $presented, viewModel: GraphViewModel())
}
