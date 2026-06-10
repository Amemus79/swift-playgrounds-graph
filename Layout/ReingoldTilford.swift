import Foundation

class ReingoldTilford {
    private let verticalSpacing: CGFloat = 150
    private let horizontalSpacing: CGFloat = 120
    
    func layout(nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        guard !nodes.isEmpty else { return }
        
        // Find root node (node with no parent)
        guard let root = nodes.first(where: { $0.parentId == nil }) else { return }
        
        // Build tree structure
        buildTree(nodes: &nodes, nodeMap: nodeMap)
        
        // First pass: calculate preliminary positions
        firstPass(node: root, nodes: &nodes, nodeMap: nodeMap)
        
        // Second pass: adjust positions to avoid overlaps
        secondPass(node: root, modifier: 0, nodes: &nodes, nodeMap: nodeMap)
        
        // Convert preliminary positions to final positions
        finalizPositions(nodes: &nodes, nodeMap: nodeMap)
    }
    
    private func buildTree(nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        var depthMap: [String: Int] = [:]
        var indexMap: [String: Int] = [:]
        
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
    
    private func firstPass(node: GraphNode, nodes: inout [GraphNode], nodeMap: [String: GraphNode]) {
        let children = nodes.filter { $0.parentId == node.childId }
        
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
        
        let children = nodes.filter { $0.parentId == node.childId }
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
}
