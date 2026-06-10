# Swift Playgrounds Directed Graph Visualization

A Swift Playgrounds application for M4 iPad Pro that visualizes directed graphs with automatic layout using the Reingold-Tilford algorithm.

## Features

- **Reingold-Tilford Layout**: Automatic hierarchical layout algorithm for tree structures
- **CSV Import**: Load graph data from CSV format (Child, Parent, Value1, Value2)
- **Dynamic Node Addition**: Add nodes to the graph at runtime with pause after each addition
- **Repeat & Pause**: After adding a node, the form pauses for 2 seconds to allow graph recalculation
- **Drag and Drop**: Reposition nodes and automatically recalculate layout
- **Zoom and Pan**: Interactive canvas navigation with pinch-to-zoom and drag-to-pan
- **Edge Length Calculation**: Automatic calculation and display of total edge lengths
- **Critical Path Analysis**: Identifies and highlights the longest depth path from root
- **Non-overlapping Edges**: Implements proper edge routing to prevent crossing lines
- **Node Highlighting**: Color-codes nodes on the critical path
- **Memory Optimized**: Minimal memory footprint suitable for iPad

## Architecture

### Models
- **GraphNode**: Represents a node with position, values, and tree metadata
- **GraphEdge**: Represents connections between nodes with calculated length
- **CSVParser**: Utility for parsing CSV formatted graph data

### Layout
- **ReingoldTilford**: Implements the Reingold-Tilford tree layout algorithm
  - First pass: Calculate preliminary x-coordinates
  - Second pass: Adjust positions to prevent overlaps
  - Finalizes positions based on tree depth

### Views
- **ContentView**: Main application container
- **GraphCanvasView**: Canvas for rendering graph and handling interactions
- **NodeView**: Individual node component with styling
- **CSVInputView**: Form for importing CSV data
- **NodeFormView**: Form for manually adding nodes with repeat and pause

### ViewModel
- **GraphViewModel**: Orchestrates graph operations and state management

## CSV Format

```
Node1,,Value1_1,Value2_1
Node2,Node1,Value1_2,Value2_2
Node3,Node1,Value1_3,Value2_3
Node4,Node2,Value1_4,Value2_4
```

- Column 1: Child ID (unique identifier for the node)
- Column 2: Parent ID (leave empty for root nodes)
- Column 3: Display Value 1
- Column 4: Display Value 2

## Node Specifications

- **Size**: 1 inch × 1.5 inches (72px × 108px at 72 DPI)
- **Display**: Shows both Value1 and Value2 separated by divider
- **Critical Path**: Highlighted in blue
- **Dragging**: Node appears with yellow tint and shadow while dragging

## Layout Behavior

- Nodes arranged left-to-right in hierarchical levels
- Parent centered above children
- Edges connect mid-right of parent to mid-left of child
- Automatic recalculation after node movement
- View automatically centers on root node after layout changes

## Node Addition Workflow

1. User clicks "+" button to open Add Node form
2. User fills in Child ID, Parent ID (optional), Value1, and Value2
3. User clicks "Add Node" button
4. Node is added and graph recalculates
5. Form pauses for 2 seconds with success message
6. User can click "Continue" to add another node or "Cancel" to close

## Canvas Interactions

- **Drag Node**: Click and drag any node to reposition it
- **Pan Canvas**: Drag on empty canvas area to move view
- **Zoom**: Pinch with two fingers to zoom in/out (0.5x to 3.0x)

## Performance Considerations

- Lazy node rendering for large graphs
- Single-pass edge drawing using Canvas
- Memory-efficient tree structure representation
- Automatic layout recalculation uses minimal intermediate storage

## Requirements

- iOS 17.0+
- SwiftUI
- iPad Pro M4 or compatible device
- Minimum deployment target: iOS 17

## Usage

1. Launch the application on iPad
2. Sample data loads automatically
3. Use "+" button to add new nodes (with repeat and pause)
4. Use document icon to import CSV data
5. Drag nodes to reposition and auto-layout
6. Pinch and drag to navigate the canvas

## Notes

- No UIKit or Combine framework dependencies (Combine only for @MainActor)
- Pure SwiftUI implementation
- No Graphviz or external graph libraries
- Minimum memory footprint with optimized data structures
- Edges rendered as straight lines with arrow endpoints
- Pause functionality allows users to observe graph recalculation after each node addition
