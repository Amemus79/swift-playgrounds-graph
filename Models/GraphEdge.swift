import Foundation

struct GraphEdge: Identifiable, Equatable {
    let id: UUID
    let fromNodeId: UUID
    let toNodeId: UUID
    var length: Double = 0
    
    init(fromNodeId: UUID, toNodeId: UUID) {
        self.id = UUID()
        self.fromNodeId = fromNodeId
        self.toNodeId = toNodeId
    }
    
    static func == (lhs: GraphEdge, rhs: GraphEdge) -> Bool {
        lhs.id == rhs.id
    }
}
