//
//  Play.swift
//  Play
//
//  Created by paku on 2024/02/27.
//

import Foundation
import SceneKit

class Play: ObservableObject {
    
    enum RotationSpeed {
        case normal
        case quick
        
        var duration: TimeInterval {
            switch self {
            case .normal: 0.3
            case .quick: 0.15
            }
        }
    }
    
    @Published var cube = Cube()
    @Published var moves: [Move] = []
    let scene = SCNScene()
    let cubeNode = SCNNode()
    var pieceNodes = [SCNNode]()
    let cameraNode = SCNNode()
    let rotationNode = SCNNode()
    
    var isRunning: Bool = false
    var request: [Move] = []
    
    init() {
        
        scene.rootNode.addChildNode(cubeNode)
        addCameraNode()
        cubeNode.addChildNode(rotationNode)
        
        build()
    }
    
    func build() {
        func createPiece(_ vec: Vector) -> SCNNode {
            // 1. pieceのBoxを生成
            let base = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
            // 2. 色を設定
            base.firstMaterial?.diffuse.contents = UIColor(white: 0.1, alpha: 1)
            // 3. nodeを作成
            let piece = SCNNode(geometry: base)
            
            // 一つのpieceに対して面の数分、色のnodeを同じpositionに生成し、表示すべき面の方へ少しでっぱりを出す。(ややshiftする)
            // なので cube.vecによって、その面は3個(Edge of up or down) or 2個(center of up, down, left, right) or 1個になる(center of middle)
            let filteredStickers = cube.stickers.filter { sticker in
                return sticker.position.isOn(piece: vec)
            }
            
            filteredStickers.forEach { sticker in
                let stickerNode = createSticker(on: sticker.face, color: sticker.color)
                piece.addChildNode(stickerNode)
            }
            
            piece.position = .init(vec: vec)
            return piece
        }
        
        func createSticker(on face: Face, color: ColorType) -> SCNNode {
            // stickerとなるnodeは 0.8で box 生成
            let base = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.1)
            base.firstMaterial?.diffuse.contents = color.uiColor
            
            let piece = SCNNode(geometry: base)
            
            let shift: Float = 0.1 + 0.02
            // 表示すべき面の方へ少しでっぱりを出す。(ややshiftする)
            if face == .front {
                piece.position = .init(0, 0, shift)
            }
            if face == .back {
                piece.position = .init(0, 0, -shift)
            }
            if face == .left {
                piece.position = .init(-shift, 0, 0)
            }
            if face == .right {
                piece.position = .init(shift, 0, 0)
            }
            if face == .up {
                piece.position = .init(0, shift, 0)
            }
            if face == .down {
                piece.position = .init(0, -shift, 0)
            }
            
            return piece
        }
        
        
        let centers: [Float] = [-1, 0, 1]
        var nodes: [SCNNode] = []
        
        // UserDefaultsからcubeを反映する前に初回 build()でpieceNodeが cubeにaddChildされているので
        // clean upする必要がある
        pieceNodes.forEach { piece in
            piece.removeFromParentNode()
        }
        pieceNodes = []
        
        // position 0,0,0 の piece以外 28この pieceを cubeNodeに貼り付ける
        for z in centers {
            for y in centers {
                for x in centers {
                    // Cubeの真ん中以外だけ、つまり見えないnodeは作成しない
                    if x != 0 || y != 0 || z != 0 {
                        let pieceNode = createPiece(.init(x: x, y: y, z: z))
                        nodes.append(pieceNode)
                        // sceneに表示するcubeNodeに1個1個 pieceを addする
                        cubeNode.addChildNode(pieceNode)
                    }
                }
            }
        }
        pieceNodes = nodes
    }
    
    func apply(move: Move) {
        
        guard !isRunning else {
            request.append(move)
            return
        }
        isRunning = true
        
        run(move)
    }
    
    private func run(_ move: Move, speed: RotationSpeed = .normal) {
        cube = cube.apply(move: move)
        
        let predicate = move.filter
        let axis = move.axis
        let angle = move.angle
        
        let targetPieces = pieceNodes.filter { piece in
            return predicate(Vector(piece.position))
        }
        
        targetPieces.forEach { piece in
            // この時点で画面から削除される(レンダリングされる）親のcube3Dから削除
            piece.removeFromParentNode()
            
            // cubeNodeにあるpiece.transformを rotationNodeの座標へと変換
            // これにより 該当のpieceのtransformは cubeNode から rotationNodeの子ノードそして新しい関係性(位置や向き)を得る。
            piece.transform = cubeNode.convertTransform(piece.transform, to: rotationNode)
            // その次に rotationNodeにaddChildする
            rotationNode.addChildNode(piece)
        }
        
        let action = SCNAction.rotate(by: CGFloat(angle), around: SCNVector3(vec: axis), duration: speed.duration)
        rotationNode.runAction(action) { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.afterAction()
            }
        }
    }
    
    func afterAction() {
        // animation(回転)した後、
        // targetPieceを rotationNodeから cubeNodeへと戻す必要がある。
        self.rotationNode.childNodes.forEach { piece in
            piece.removeFromParentNode()
            // cubeNodeに
            piece.transform = self.cubeNode.convertTransform(piece.transform, from: self.rotationNode)
            self.cubeNode.addChildNode(piece)
            
            // roundedをしないと回転による、小数点の誤差で正常な計算にならないため
            piece.position = SCNVector3(x: round(piece.position.x), y: round(piece.position.y), z: round(piece.position.z))
        }
        
        if request.isEmpty {
            isRunning = false
        } else {
            let nextMove = request.removeFirst()
            run(nextMove, speed: .quick)
        }
    }
    
    private func addCameraNode() {
        let camera = SCNCamera()
        camera.projectionDirection = .horizontal
        
        cameraNode.camera = camera
        cameraNode.position =  SCNVector3(7, 7, 10)
        cameraNode.constraints = [SCNLookAtConstraint(target: cubeNode)]
        scene.rootNode.addChildNode(cameraNode)
    }
    
    
}

extension Vector {
    
    init(_ vec: SCNVector3) {
        self.init(x: vec.x, y: vec.y, z: vec.z)
    }
    
    func isOn(piece: Self) -> Bool {
        // これを行う理由は
        // front or backの場合 piece.zは 1.0に対して sticker.zは 1.5のため
        
        // front or back
        if piece.x == self.x && piece.y == self.y {
            return piece.z != self.z && (piece.z * self.z) > 0
        }
        
        // left or right
        if piece.z == self.z && piece.y == self.y {
            return piece.x != self.x && (piece.x * self.x) > 0
        }
        
        // up or down
        if piece.x == self.x && piece.z == self.z {
            return piece.y != self.y && (piece.y * self.y) > 0
        }
        return false
    }
}

extension SCNVector3 {
    
    init(vec: Vector) {
        self.init(x: vec.x, y: vec.y, z: vec.z)
    }
}
