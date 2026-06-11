import SwiftUI

struct GraphCanvasView: View {
    @ObservedObject var viewModel: GraphViewModel
    @State private var draggedNodeId: UUID?
    @State private var lastDragLocation: CGPoint = .zero
    
    var body: some View {
        ZStack {
            // Canvas background
            Color.white
            
            // Graph
            Canvas { context in
                // Draw edges
                for edge in viewModel.edges {
                    if let fromNode = viewModel.nodes.first(where: { $0.id == edge.fromNodeId }),
                       let toNode = viewModel.nodes.first(where: { $0.id == edge.toNodeId }) {
                        drawEdge(from: fromNode, to: toNode, in: context)
                    }
                }
            }
            .contentShape(Rectangle())
            
            // Nodes
            ForEach(viewModel.nodes) { node in
                NodeView(node: node, viewModel: viewModel)
                    .offset(
                        x: viewModel.canvasOffset.x + node.position.x * viewModel.zoomLevel,
                        y: viewModel.canvasOffset.y + node.position.y * viewModel.zoomLevel
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                draggedNodeId = node.id
                                let newPos = CGPoint(
                                    x: (value.location.x - viewModel.canvasOffset.x) / viewModel.zoomLevel,
                                    y: (value.location.y - viewModel.canvasOffset.y) / viewModel.zoomLevel
                                )
                                viewModel.moveNodeTemporarily(node.id, to: newPos)
                            }
                            .onEnded { _ in
                                viewModel.finalizeDraggedNode()
                                draggedNodeId = nil
                            }
                    )
            }
        }
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { scale in
                        viewModel.setZoom(viewModel.zoomLevel * scale)
                    },
                DragGesture()
                    .onChanged { value in
                        if draggedNodeId == nil {
                            viewModel.panCanvas(by: value.translation)
                            lastDragLocation = value.location
                        }
                    }
            )
        )
        #if os(macOS)
        .onReceive(Publishers.keyDown) { keyCode in
            handleMacOSKeyboard(keyCode)
        }
        #endif
    }
    
    #if os(macOS)
    private func handleMacOSKeyboard(_ keyCode: NSEvent.EventType) {
        // Keyboard shortcuts for macOS
        // Space for pan, +/- for zoom, etc.
    }
    #endif
    
    private func drawEdge(from: GraphNode, to: GraphNode, in context: GraphicsContext) {
        let fromX = viewModel.canvasOffset.x + from.position.x * viewModel.zoomLevel + GraphNode.nodeWidth / 2
        let fromY = viewModel.canvasOffset.y + from.position.y * viewModel.zoomLevel + GraphNode.nodeHeight / 2
        
        let toX = viewModel.canvasOffset.x + to.position.x * viewModel.zoomLevel - GraphNode.nodeWidth / 2
        let toY = viewModel.canvasOffset.y + to.position.y * viewModel.zoomLevel + GraphNode.nodeHeight / 2
        
        let startPoint = CGPoint(x: fromX, y: fromY)
        let endPoint = CGPoint(x: toX, y: toY)
        
        // Draw line
        var path = Path()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        context.stroke(
            path,
            with: .color(.black),
            lineWidth: 1.5
        )
        
        // Draw arrow
        drawArrow(from: startPoint, to: endPoint, in: context)
    }
    
    private func drawArrow(from: CGPoint, to: CGPoint, in context: GraphicsContext) {
        let arrowLength: CGFloat = 15
        let arrowAngle: CGFloat = .pi / 6
        
        let dx = to.x - from.x
        let dy = to.y - from.y
        let angle = atan2(dy, dx)
        
        let leftAngle = angle + arrowAngle
        let rightAngle = angle - arrowAngle
        
        let leftPoint = CGPoint(
            x: to.x - arrowLength * cos(leftAngle),
            y: to.y - arrowLength * sin(leftAngle)
        )
        
        let rightPoint = CGPoint(
            x: to.x - arrowLength * cos(rightAngle),
            y: to.y - arrowLength * sin(rightAngle)
        )
        
        var arrowPath = Path()
        arrowPath.move(to: to)
        arrowPath.addLine(to: leftPoint)
        arrowPath.move(to: to)
        arrowPath.addLine(to: rightPoint)
        
        context.stroke(
            arrowPath,
            with: .color(.black),
            lineWidth: 1.5
        )
    }
}

#if os(macOS)
extension Publishers {
    static var keyDown: Publisher<NSEvent.EventType, Never> {
        return NSEvent.publisher(for: NSWindow.didUpdateNotification).map { _ in
            NSEvent.EventType.keyDown
        }.eraseToAnyPublisher()
    }
}
#endif

#Preview {
    ContentView()
}
