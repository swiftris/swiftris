let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 20
let LevelThreshold = 100

protocol SwiftrisDelegate {
    func gameDidEnd(swiftris: Swiftris)
    func gameDidBegin(swiftris: Swiftris)
    func gameShapeDidLand(swiftris: Swiftris)
    func gameShapeDidMove(swiftris: Swiftris)
    func gameShapeDidDrop(swiftris: Swiftris)
    func gameDidLevelUp(swiftris: Swiftris)
}

class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    
    var score = 0
    var level = 1
    
    var land_tick:Int = 0
    
    var drop:Bool = false
    
    var move:Bool = false
    
    //初期化
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        //新しいブロック生成
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        return (fallingShape, nextShape)
    }
    
    //そのぶろっくが正式な位置にいるかどうか
    //ブロックの形にちゃんとなっているか
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(self)
    }
    
    
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                    return true
            }
        }
        return false
    }
    
    //左が埋まってたら left ,右が埋まってたら right ,それ以外は nothing
    func detect_RL_IllegalPlacement() -> String {
        guard let shape = fallingShape else {
            return "nothing"
        }
        for block in shape.blocks {
            if block.column < 0{
                return "left"
            }
            if block.column >= NumColumns{
                return "right"
            }
        }
        return "nothing"
    }

    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
     //#10
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        //removedlines
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reverse() {
            var rowOfBlocks = Array<Block>()
            //#11
            for column in 0..<NumColumns {
                //ある一列を一個づつ埋まっているかいないかの検査
                //あったらblockに代入、なかったらスキップ
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            //横一列が埋まっている場合
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    //揃った横一列のブロックの場所にnull(消す)を代入
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        //#12
        if removedLines.count == 0 {
            return ([], [])
        }
        //#13
        //スコア換算
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        //fallenblocks
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            //result of array(横列消しの処理後の列達の中の一つの列)
            var fallenBlocksArray = Array<Block>()
            //#14
            for row in (1..<removedLines[0][0].row).reverse()
                {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                    
                //以下のwhile文が落ちる処理!!!!!!!
                    //    newRows <  19 && １個下にブロックがない
                //while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                //    newRow += 1
                //}
                if newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil {
                           newRow += removedLines.count
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        
        drop = true
        
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(self)
    }
    
    //クロージャ関数tick()　の　中身!!1!!!!!!!!!!
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        //落ちているブロックを一列落とす
        shape.lowerShapeByOneRow()
        //block位置が通常と違う場合
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            //game画面場外にブロックがある時
            if detectIllegalPlacement() {
                endGame()
            } else {
                //block固定
                if land_tick > 3 || drop == true{
                    drop = false
                    land_tick = 0
                    settleShape()
                }
            }
        } else {
            //block位置がどこにも触れていない状態？
            delegate?.gameShapeDidMove(self)
            //ブロックに触れているかの判定
            if detectTouch() {
                //ブロック固定
                if land_tick > 3 || drop == true{
                    drop = false
                    land_tick = 0
                    settleShape()
                }
            }
        }
    }
    
    
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.rotateClockwise()
        if detectIllegalPlacement() == true{
//            guard detectIllegalPlacement() == false else {
//                shape.rotateCounterClockwise()
//                return
//            }
            if detect_RL_IllegalPlacement() == "right"{
                shape.shiftLeftByOneColumn()
                if detect_RL_IllegalPlacement() == "right"{
                    shape.shiftLeftByOneColumn()
                    if detect_RL_IllegalPlacement() == "right"{
                        shape.shiftRightByOneColumn()
                        shape.shiftRightByOneColumn()
                        shape.rotateCounterClockwise()
                        return
                    }
                }
            }else if detect_RL_IllegalPlacement() == "left"{
                shape.shiftRightByOneColumn()
                if detect_RL_IllegalPlacement() == "left"{
                    shape.shiftRightByOneColumn()
                    if detect_RL_IllegalPlacement() == "left"{
                        shape.shiftLeftByOneColumn()
                        shape.shiftLeftByOneColumn()
                        shape.rotateCounterClockwise()
                        return
                    }
                }
            }
            
            if detectIllegalPlacement() == true{
                shape.raiseShapeByOneRow()
                if detectIllegalPlacement() == true{
                    shape.raiseShapeByOneRow()
                    if detectIllegalPlacement() == true{
                        shape.lowerShapeByOneRow()
                        shape.lowerShapeByOneRow()
                        shape.rotateCounterClockwise()
                        return
                    }
                }
            }
        }
        
        delegate?.gameShapeDidMove(self)
        
    }
    
    
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
}
