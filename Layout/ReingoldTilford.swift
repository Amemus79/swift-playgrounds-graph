import Foundation

class ReingoldTilford {
    private let verticalSpacing: CGFloat = 150
    private let horizontalSpacing: CGFloat = 120
    private var enableEdgeLengthOptimization = true
    
    func layout(nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        guard !nodes.isEmpty else { return }
        
        // Find root node (node with no parent)
        guard let root = nodes.first(where: { $0.parentId == nil }) else { return }
        
        // Build tree structure
        buildTree(nodes: &nodes, nodeMap: nodeMap)
        
        // Optional: Optimize child order to minimize edge lengths
        if enableEdgeLengthOptimization {
            optimizeChildOrder(nodes: &nodes, nodeMap: nodeMap)
        }
        
        // First pass: calculate preliminary positions
        firstPass(node: root, nodes: &nodes, nodeMap: nodeMap)
        
        // Second pass: adjust positions to avoid overlaps
        secondPass(node: root, modifier: 0, nodes: &nodes, nodeMap: nodeMap)
        
        // Convert preliminary positions to final positions
        finalizPositions(nodes: &nodes, nodeMap: nodeMap)
    }
    
    private func buildTree(nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        var depthMap: [String: Int] = [:]
        
        // Calculate depths
        func calculateDepth(_ childId: String) -> Int {
            if let depth = depthMap[childId] {
                return depth
            }
            
            if let node = nodeMap[childId], let parentId = node.parentId {
                let parentDepth = calculateDepth(parentId)
                depthMap[childId] = parentDepth + 1
                return parentDepth + 1
            }
            
            depthMap[childId] = 0
            return 0
        }
        
        for node in nodes {
            let depth = calculateDepth(node.childId)
            if var mutableNode = nodes.first(where: { $0.childId == node.childId }) {
                mutableNode.treeDepth = depth
                if let index = nodes.firstIndex(of: mutableNode) {
                    nodes[index].treeDepth = depth
                }
            }
        }
        
        // Calculate sibling indices
        let siblings = Dictionary(grouping: nodes, by: { $0.parentId })
        for (_, siblingGroup) in siblings {
            for (index, node) in siblingGroup.enumerated() {
                if let nodeIndex = nodes.firstIndex(of: node) {
                    nodes[nodeIndex].treeIndex = index
                }
            }
        }
    }
    
    private func optimizeChildOrder(nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        // Group nodes by parent
        let childrenByParent = Dictionary(grouping: nodes, by: { $0.parentId })
        
        // For each parent with multiple children, optimize their order
        for (parentId, children) in childrenByParent where children.count > 1, parentId != nil {
            // Calculate subtree sizes for each child
            var childOrder: [(child: GraphNode, subtreeSize: Int)] = []
            
            for child in children {
                let subtreeSize = calculateSubtreeSize(child: child, nodes: nodes)
                childOrder.append((child: child, subtreeSize: subtreeSize))
            }
            
            // Sort children by subtree size (larger subtrees closer to center minimizes edge length)
            childOrder.sort { $0.subtreeSize > $1.subtreeSize }
            
            // Update treeIndex based on optimized order
            for (index, item) in childOrder.enumerated() {
                if let nodeIndex = nodes.firstIndex(of: item.child) {
                    nodes[nodeIndex].treeIndex = index
                }
            }
        }
    }
    
    private func calculateSubtreeSize(child: GraphNode, nodes: [GraphNode]) -> Int {
        var size = 1
        let descendants = nodes.filter { $0.parentId == child.childId }
        for descendant in descendants {
            size += calculateSubtreeSize(child: descendant, nodes: nodes)
        }
        return size
    }
    
    private func firstPass(node: GraphNode, nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        var children = nodes.filter { $0.parentId == node.childId }
        
        // Sort children by treeIndex to maintain optimized order
        children.sort { $0.treeIndex < $1.treeIndex }
        
        if children.isEmpty {
            // Leaf node
            if let index = nodes.firstIndex(of: node) {
                nodes[index].preliminaryX = 0
                nodes[index].modifier = 0
            }
        } else {
            // Internal node - recursively process children
            for child in children {
                firstPass(node: child, nodes: &nodes, nodeMap: nodeMap)
            }
            
            // Calculate preliminary x as average of children
            let childXValues = children.map { $0.preliminaryX }
            let avgX = childXValues.reduce(0, +) / Double(childXValues.count)
            
            if let index = nodes.firstIndex(of: node) {
                nodes[index].preliminaryX = avgX
            }
        }
    }
    
    private func secondPass(node: GraphNode, modifier: CGFloat, nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        if let index = nodes.firstIndex(of: node) {
            let nodeWidth = GraphNode.nodeWidth + horizontalSpacing
            nodes[index].preliminaryX = nodes[index].preliminaryX + modifier
        }
        
        var children = nodes.filter { $0.parentId == node.childId }
        children.sort { $0.treeIndex < $1.treeIndex }
        
        for child in children {
            secondPass(node: child, modifier: modifier + node.preliminaryX, nodes: &nodes, nodeMap: nodeMap)
        }
    }
    
    private func finalizPositions(nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        var positions: [String: CGPoint] = [:]
        
        for node in nodes {
            let x = node.preliminaryX * Double(horizontalSpacing)
            let y = CGFloat(node.treeDepth) * verticalSpacing
            positions[node.childId] = CGPoint(x: x, y: y)
        }
        
        for i in 0..<nodes.count {
            if let pos = positions[nodes[i].childId] {
                nodes[i].position = pos
            }
        }
    }
    
    // Optional: Toggle edge length optimization
    func setEdgeLengthOptimization(_ enabled: Bool) {
        enableEdgeLengthOptimization = enabled
    }
}
