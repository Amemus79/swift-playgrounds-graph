import SwiftUI
import Combine

@MainActor
class GraphViewModel: ObservableObject {
    @Published var nodes: [GraphNode] = []
    @Published var edges: [GraphEdge] = []
    @Published var totalEdgeLength: Double = 0
    @Published var zoomLevel: CGFloat = 1.0
    @Published var canvasOffset: CGPoint = .zero
    @Published var selectedNodeId: UUID?
    @Published var criticalPathLength: Int = 0
    
    private let reingoldTilford = ReingoldTilford()
    private var nodeMapByChildId: [String: GraphNode] = [:]
    private var nodeMapById: [UUID: GraphNode] = [:]
    
    func loadCSV(_ csvString: String) {
        guard let parsedData = CSVParser.parseCSV(csvString) else { return }
        
        nodes = parsedData.map { GraphNode(childId: $0.childId, parentId: $0.parentId, value1: $0.value1, value2: $0.value2) }
        
        buildNodeMaps()
        createEdges()
        layoutGraph()
        calculateCriticalPath()
        centerOnRoot()
    }
    
    func addNode(childId: String, parentId: String?, value1: String, value2: String) {
        let newNode = GraphNode(childId: childId, parentId: parentId, value1: value1, value2: value2)
        nodes.append(newNode)
        
        buildNodeMaps()
        createEdges()
        layoutGraph()
        calculateCriticalPath()
        centerOnRoot()
    }
    
    private func buildNodeMaps() {
        nodeMapByChildId = Dictionary(uniqueKeysWithValues: nodes.map { ($0.childId, $0) })
        nodeMapById = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
    }
    
    private func createEdges() {
        edges = []
        for node in nodes {
            if let parentId = node.parentId,
               let parentNode = nodes.first(where: { $0.childId == parentId }) {
                let edge = GraphEdge(fromNodeId: parentNode.id, toNodeId: node.id)
                edges.append(edge)
            }
        }
    }
    
    private func layoutGraph() {
        reingoldTilford.layout(nodes: &nodes, nodeMap: nodeMapByChildId)
        calculateEdgeLengths()
    }
    
    private func calculateEdgeLengths() {
        totalEdgeLength = 0
        for i in 0..<edges.count {
            if let fromNode = nodes.first(where: { $0.id == edges[i].fromNodeId }),
               let toNode = nodes.first(where: { $0.id == edges[i].toNodeId }) {
                let distance = hypot(toNode.position.x - fromNode.position.x,
                                   toNode.position.y - fromNode.position.y)
                edges[i].length = distance
                totalEdgeLength += distance
            }
        }
    }
    
    private func calculateCriticalPath() {
        // Find root node
        guard let root = nodes.first(where: { $0.parentId == nil }) else {
            criticalPathLength = 0
            return
        }
        
        // Reset critical path markers
        for i in 0..<nodes.count {
            nodes[i].isOnCriticalPath = false
        }
        
        // Calculate deepest path from root
        let deepestPath = findDeepestPath(from: root)
        criticalPathLength = deepestPath.count
        
        // Mark nodes on critical path
        for node in deepestPath {
            if let index = nodes.firstIndex(of: node) {
                nodes[index].isOnCriticalPath = true
            }
        }
    }
    
    private func findDeepestPath(from node: GraphNode) -> [GraphNode] {
        let children = nodes.filter { $0.parentId == node.childId }
        
        if children.isEmpty {
            return [node]
        }
        
        var deepestPath = [node]
        var maxDepth = 0
        
        for child in children {
            let childPath = findDeepestPath(from: child)
            if childPath.count > maxDepth {
                maxDepth = childPath.count
                deepestPath = [node] + childPath
            }
        }
        
        return deepestPath
    }
    
    private func centerOnRoot() {
        guard let root = nodes.first(where: { $0.parentId == nil }) else { return }
        
        canvasOffset = CGPoint(
            x: -root.position.x + 400,
            y: -root.position.y + 200
        )
    }
    
    func updateNodePosition(_ nodeId: UUID, to position: CGPoint) {
        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            nodes[index].position = position
            calculateEdgeLengths()
        }
    }
    
    func moveNodeTemporarily(_ nodeId: UUID, to position: CGPoint) {
        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            nodes[index].position = position
            nodes[index].isDragging = true
        }
    }
    
    func finalizeDraggedNode() {
        for i in 0..<nodes.count {
            if nodes[i].isDragging {
                nodes[i].isDragging = false
                layoutGraph()
                centerOnRoot()
                break
            }
        }
    }
    
    func setZoom(_ zoom: CGFloat) {
        zoomLevel = max(0.5, min(3.0, zoom))
    }
    
    func panCanvas(by offset: CGPoint) {
        canvasOffset.x += offset.x
        canvasOffset.y += offset.y
    }
}
