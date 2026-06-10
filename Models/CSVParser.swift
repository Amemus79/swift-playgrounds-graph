import Foundation

struct CSVParser {
    static func parseCSV(_ csvString: String) -> [(childId: String, parentId: String?, value1: String, value2: String)]? {
        let lines = csvString.split(separator: "\n", omittingEmptySubsequences: true)
        var nodes: [(childId: String, parentId: String?, value1: String, value2: String)] = []
        
        for line in lines {
            let components = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            
            guard components.count >= 3 else { continue }
            
            let childId = components[0]
            let parentId = components.count > 1 && !components[1].isEmpty ? components[1] : nil
            let value1 = components.count > 2 ? components[2] : ""
            let value2 = components.count > 3 ? components[3] : ""
            
            nodes.append((childId: childId, parentId: parentId, value1: value1, value2: value2))
        }
        
        return nodes.isEmpty ? nil : nodes
    }
}
