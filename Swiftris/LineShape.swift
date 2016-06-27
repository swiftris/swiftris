class LineShape:Shape {
    /*
        Orientations 0 and 180:
    
            | 0•|
            | 1 |
            | 2 |
            | 3 |
    
        Orientations 90 and 270:

        | 0 | 1•| 2 | 3 |
    
    • marks the row/column indicator for the shape
    
    */
    
    // Hinges about the second block
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(0, 0), (0, 1), (0, 2), (0, 3)],
            Orientation.Ninety:     [(-1,1), (0, 1), (1, 1), (2, 1)],//(x,0) -> (x,1)に変更6/10
            Orientation.OneEighty:  [(0, 0), (0, 1), (0, 2), (0, 3)],
            Orientation.TwoSeventy: [(-1,1), (0, 1), (1, 1), (2, 1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[FourthBlockIdx]],
            Orientation.Ninety:     blocks,
            Orientation.OneEighty:  [blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: blocks
        ]
    }
    
    override var rightBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       blocks,
            Orientation.Ninety:     [blocks[FourthBlockIdx]],
            Orientation.OneEighty:  blocks,
            Orientation.TwoSeventy: [blocks[FourthBlockIdx]]
        ]
    }

}
