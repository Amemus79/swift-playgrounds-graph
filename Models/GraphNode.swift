import Foundation

struct GraphNode: Identifiable, Equatable {
    let id: UUID
    let childId: String
    let parentId: String?
    let value1: String
    let value2: String
    var position: CGPoint = .zero
    var treeDepth: Int = 0
    var treeIndex: Int = 0
    var preliminaryX: Double = 0
    var modifier: Double = 0
    var isDragging: Bool = false
    var isOnCriticalPath: Bool = false
    
    static let nodeWidth: CGFloat = 72  // 1 inch at 72 DPI
    static let nodeHeight: CGFloat = 108  // 1.5 inches at 72 DPI
    
    init(childId: String, parentId: String?, value1: String, value2: String) {
        self.id = UUID()
        self.childId = childId
        self.parentId = parentId
        self.value1 = value1
        self.value2 = value2
    }
    
    static func == (lhs: GraphNode, rhs: GraphNode) -> Bool {
        lhs.id == rhs.id
    }
}
