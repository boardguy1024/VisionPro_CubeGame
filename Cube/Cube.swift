//
//  Cube.swift
//  Cube
//
//  Created by paku on 2024/02/20.
//

import Foundation
import SwiftUI

let onFace: Float = 1.5

enum ColorType: String, CaseIterable {
    case white = "W"
    case red = "R"
    case green = "G"
    case yellow = "Y"
    case orange = "O"
    case blue = "B"
    
    var color: Color {
        switch self {
        case .white: .white
        case .red: .red
        case .green: .green
        case .yellow: .yellow
        case .orange: .orange
        case .blue: .blue
        }
    }
}

enum Face: Int, CaseIterable {
    case up = 0
    case down = 1
    case front = 2
    case back = 3
    case left = 4
    case right = 5
}

struct Vector: Equatable {
    let x: Float
    let y: Float
    let z: Float
    
    var values: (Float, Float, Float) {
        (x, y, z)
    }
    
    var negative: Vector {
        Self(x: -x, y: -y, z: -z)
    }
}

extension Vector {
    func rotate(on axis: Vector, angle: Rotation) -> Vector {
                
        var (x, y, z) = values
        
        switch axis {
        case Axis.X, Axis.X.negative:
            // x軸をベースに縦回しの場合、yとzが変わる
            (y, z) = rotate2D(y, z, angle)
            
        case Axis.Y, Axis.Y.negative:
            // YAW rotationなので x, z
            (z, x) = rotate2D(z, x, angle)
            
        case Axis.Z, Axis.Z.negative:
            // z軸をベースに 正面の面全体を左or右に回すイメージ
            (x, y) = rotate2D(x, y, angle)
        default:
            assert(false, "Invalid axis")
        }
      
        return Vector(x: x, y: y, z: z)
        
        /*
         vector ( x, y ) 回転配列の計算
         x' = x * cosθ - y * sinθ
         y' = x * sinθ + y * cosθ
         
         */
        func rotate2D(_ x: Float, _ y: Float, _ angle: Rotation) -> (Float, Float) {
            let sin_t: Float = sin(angle.angle)
            let cos_t: Float = cos(angle.angle)
            
            let resultX =  x * cos_t - y * sin_t
            let resultY = x * sin_t + y * cos_t
            return (cleanup(resultX), cleanup(resultY))
        }
        
        // 小数点 1桁を四捨五入
        func cleanup(_ value: Float) -> Float  {
            // 2倍にすると必ず整数なので、こう計算して、割り切れない小数点によるズレを防ぐため
            return roundf(value * 2) / 2
        }
    }
}

enum Rotation {
    case clockwise
    case counterClockwire
    case filp
    
    var angle: Float {
        switch self {
        // 数学の回転ではデフォルトが反時計回りなので -にする
        case .clockwise: -.pi / 2
        case .counterClockwire: .pi / 2
        case .filp: .pi
        }
    }
}

struct Axis {
    static let X = Vector(x: 1, y: 0, z: 0)
    static let Y = Vector(x: 0, y: 1, z: 0)
    static let Z = Vector(x: 0, y: 0, z: 1)
}

struct Sticker {
    let color: ColorType
    var position: Vector
    
    var face: Face {
        if position.y == onFace {
            return .up
        } else if position.y == -onFace {
            return .down
        } else if position.x == onFace {
            return .right
        } else if position.x == -onFace {
            return .left
        } else if position.z == onFace {
            return .front
        } else if position.z == -onFace {
            return .back
        } else {
            assert(false, "Invalied Geometry")
        }
    }
    
    // 面に対して 0..<9 の indexを返す
    var index: Int {
        let (x, y, z) = position.values
        
        // x,yは 左上から順番にくる
        // (x: -1, y: 1) (x: 0, y: 1) (x: 1, y: 1)
        // (x: -1, y: 0) (x: 0, y: 0) (x: 1, y: 0)
        // (x: -1, y: -1) (x: 0, y: -1) (x: 1, y: -1)
        
        // indexは その順番
        switch face {
        // upの場合、yは関係ないので yが zになる
        case .up: return indexOnFace(x, z) // white
        case .down: return indexOnFace(x, -z) // red
        case .front: return indexOnFace(x, -y) // green
        case .back: return indexOnFace(-x, -y) // yellow
        case .left: return indexOnFace(z, -y) // orange
        case .right: return indexOnFace(-z, -y) // blue
        }
        
        func indexOnFace(_ x: Float, _ y: Float) -> Int {
            // 0 ~ 9
            return (Int(y) + 1) * 3 + (Int(x) + 1)
        }
        
        /*
         2D展開図                      ( UP )
                                 white white white
                                 white white white
                                 white white white
         
              (  LEFT  )             ( FRONT )           ( BLUE )            ( BACK )
         orange orange orange    green green green    blue blue blue    yellow yellow yellow
         orange orange orange    green green green    blue blue blue    yellow yellow yellow
         orange orange orange    green green green    blue blue blue    yellow yellow yellow
         
                                     ( DOWN )
                                   red red red
                                   red red red
                                   red red red
         
         */
    }
    
    func rotate(on axis: Vector, by angle: Rotation) -> Sticker {
        var rotated = self
        
        rotated.position = position.rotate(on: axis, angle: angle)
        
        return rotated
    }
}

struct Cube {
    // 全てのコマにはる1個1個のステッカー count = 54
    var stickers: [Sticker] = []
    
    init() {
        for (face, color) in zip(Face.allCases, ColorType.allCases) {
            let positions: [Float] = [-1.0, 0, 1.0]
            // y*3 , x*3 = 1面=9個
            // [[x: -1, y: -1], [x: 0, y: -1], [x: 1, y: -1]]
            // [[x: -1, y: 0], [x: 0, y: 0], [x: 1, y: 0]]
            // [[x: -1, y: 1], [x: 0, y: 1], [x: 1, y: 1]]
            for y in positions {
                for x in positions {
                    
                    let position = stickerPosition(x, y, face: face)
                    let sticker = Sticker(color: color, position: position)

                    self.stickers.append(sticker)
                }
            }
        }
    }
    
    func stickerPosition(_ x: Float, _ y: Float, face: Face) -> Vector {
        // 左上から順番に
        /*
         0 1 2
         3 4 5
         6 7 8
         */
        // [[x: -1, y: -1], [x: 0, y: -1], [x: 1, y: -1]]
        // [[x: -1, y: 0], [x: 0, y: 0], [x: 1, y: 0]]
        // [[x: -1, y: 1], [x: 0, y: 1], [x: 1, y: 1]]
        // なので 左上から順番に割与えるために 必要によって (ー)を使って反転させる
        switch face {
        case .up: Vector(x: x, y: onFace, z: y)
        case .down: Vector(x: x, y: -onFace, z: -y)
        case .left: Vector(x: -onFace, y: y, z: x)
        case .front: Vector(x: x, y: -y, z: onFace)
        case .right: Vector(x: onFace, y: -y, z: -x)
        case .back: Vector(x: x, y: y, z: -onFace)
        }
    }
    
    func as2D() -> Cube2D {
        var cube2D = Cube2D()
                
        stickers.forEach { sticker in
            cube2D.setColorType(of: sticker.face, index: sticker.index, color: sticker.color)
        }
        
//        stickers.forEach { sticker in
//            print("face: \(sticker.face)")
//            print("position: \(sticker.position)")
//        }
            
        return cube2D
    }
}


extension Sticker: CustomStringConvertible {
    var description: String {
        "\(color):\(position)"
    }
}

extension Vector: CustomStringConvertible {
    var description: String {
        "x:\(x), y:\(y), z:\(z)"
    }
}
