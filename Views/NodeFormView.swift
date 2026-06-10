import SwiftUI

struct NodeFormView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: GraphViewModel
    @State private var childId = ""
    @State private var parentId = ""
    @State private var value1 = ""
    @State private var value2 = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("Add Node")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Child ID:")
                            .frame(width: 80, alignment: .leading)
                        TextField("e.g., Node1", text: $childId)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("Parent ID:")
                            .frame(width: 80, alignment: .leading)
                        TextField("Leave empty for root", text: $parentId)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("Value 1:")
                            .frame(width: 80, alignment: .leading)
                        TextField("Display value 1", text: $value1)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("Value 2:")
                            .frame(width: 80, alignment: .leading)
                        TextField("Display value 2", text: $value2)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .font(.caption)
                
                if showSuccess {
                    Text("Node added successfully!")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(.red)
                    
                    Spacer()
                    
                    Button("Add Node") {
                        viewModel.addNode(
                            childId: childId,
                            parentId: parentId.isEmpty ? nil : parentId,
                            value1: value1,
                            value2: value2
                        )
                        
                        childId = ""
                        parentId = ""
                        value1 = ""
                        value2 = ""
                        
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isPresented = false
                        }
                    }
                    .foregroundStyle(.blue)
                    .disabled(childId.isEmpty)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
        }
    }
}

#Preview {
    @State var presented = true
    return NodeFormView(isPresented: $presented, viewModel: GraphViewModel())
}
