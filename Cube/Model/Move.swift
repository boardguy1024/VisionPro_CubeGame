//
//  Move.swift
//  Cube
//
//  Created by paku on 2024/02/23.
//

import SwiftUI

enum MoveType: Character, CaseIterable, Codable {
    case U = "U"
    case D = "D"
    case F = "F"
    case B = "B"
    case R = "R"
    case L = "L"
    case Uw = "u"
    case Dw = "d"
    case Fw = "f"
    case Bw = "b"
    case Rw = "r"
    case Lw = "l"
    case x = "x"
    case y = "y"
    case z = "z"
    case M = "M"
    case E = "E"
    case S = "S"
    
    var axis: Vector {
        switch self {
        case .R, .Rw, .x:
            Axis.X
        case .L, .Lw, .M:
            Axis.X.negative
        case .U, .Uw, .y:
            Axis.Y
        case .D, .Dw, .E:
            Axis.Y.negative
        case .F, .Fw, .z, .S:
            Axis.Z
        case .B, .Bw:
            Axis.Z.negative
        }
    }
    
    var filter: (Sticker) -> Bool {
        switch self {
        case .R: return { $0.position.x > 0 }
        case .L: return { $0.position.x < 0 }
        case .U: return { $0.position.y > 0 }
        case .D: return { $0.position.y < 0 }
        case .F: return { $0.position.z > 0 }
        case .B: return { $0.position.z < 0 }
        case .Rw: return { $0.position.x >= 0 }
        case .Lw: return { $0.position.x <= 0 }
        case .Uw: return { $0.position.y >= 0 }
        case .Dw: return { $0.position.y <= 0 }
        case .Fw: return { $0.position.z >= 0 }
        case .Bw: return { $0.position.z <= 0 }
        case .x: return { _ in true }
        case .y: return { _ in true }
        case .z: return { _ in true }
        case .M: return { $0.position.x == 0 }
        case .E: return { $0.position.y == 0 }
        case .S: return { $0.position.z == 0 }
        }
    }
}

struct Move: Codable {
    let moveType: MoveType
    let prime: Bool
    let twice: Bool
    
    init(_ moveType: MoveType, prime: Bool = false, twice: Bool = false ) {
        self.moveType = moveType
        self.prime = prime
        self.twice = twice
    }
    
    var reversed: Move {
        return Self(moveType, prime: !prime, twice: twice)
    }
    
    // 方向の文字列 Keyで それに値する Value(Move?)が返される
    static func from(_ moveStr: String) -> Move? {
        allMovesDic[moveStr]
    }
    
    static func parse(_ movesStr: String) -> [Move] {
        movesStr.components(separatedBy: " ").reduce([], { result, str in
            guard let move = from(str) else { return result }
            return result + [move]
        })
    }
    
    
    static let allMovesDic: [String: Move] = [
        // face turn
        
        "U": Move(.U),
        "D": Move(.D),
        "F": Move(.F),
        "B": Move(.B),
        "R": Move(.R),
        "L": Move(.L),
        
        "U'": Move(.U, prime: true),
        "D'": Move(.D, prime: true),
        "F'": Move(.F, prime: true),
        "B'": Move(.B, prime: true),
        "R'": Move(.R, prime: true),
        "L'": Move(.L, prime: true),
        
        "U2": Move(.U, twice: true),
        "D2": Move(.D, twice: true),
        "F2": Move(.F, twice: true),
        "B2": Move(.B, twice: true),
        "R2": Move(.R, twice: true),
        "L2": Move(.L, twice: true),
        
        // wide moves
        
        "Uw": Move(.Uw),
        "Dw": Move(.Dw),
        "Fw": Move(.Fw),
        "Bw": Move(.Bw),
        "Rw": Move(.Rw),
        "Lw": Move(.Lw),
        
        "Uw'": Move(.Uw, prime: true),
        "Dw'": Move(.Dw, prime: true),
        "Fw'": Move(.Fw, prime: true),
        "Bw'": Move(.Bw, prime: true),
        "Rw'": Move(.Rw, prime: true),
        "Lw'": Move(.Lw, prime: true),
        
        "Uw2": Move(.Uw, twice: true),
        "Dw2": Move(.Dw, twice: true),
        "Fw2": Move(.Fw, twice: true),
        "Bw2": Move(.Bw, twice: true),
        "Rw2": Move(.Rw, twice: true),
        "Lw2": Move(.Lw, twice: true),
        
        // wide moves (alias, lowercase)
        
        "u": Move(.Uw),
        "d": Move(.Dw),
        "f": Move(.Fw),
        "b": Move(.Bw),
        "r": Move(.Rw),
        "l": Move(.Lw),
        "u'": Move(.Uw, prime: true),
        "d'": Move(.Dw, prime: true),
        "f'": Move(.Fw, prime: true),
        "b'": Move(.Bw, prime: true),
        "r'": Move(.Rw, prime: true),
        "l'": Move(.Lw, prime: true),
        
        "u2": Move(.Uw, twice: true),
        "d2": Move(.Dw, twice: true),
        "f2": Move(.Fw, twice: true),
        "b2": Move(.Bw, twice: true),
        "r2": Move(.Rw, twice: true),
        "l2": Move(.Lw, twice: true),
        
        // cube rotation
        
        "x": Move(.x),
        "y": Move(.y),
        "z": Move(.z),
        
        "x'": Move(.x, prime: true),
        "y'": Move(.y, prime: true),
        "z'": Move(.z, prime: true),
        
        "x2": Move(.x, twice: true),
        "y2": Move(.y, twice: true),
        "z2": Move(.z, twice: true),
        
        // middle layer
        
        "M": Move(.M),
        "E": Move(.E),
        "S": Move(.S),
        
        "M'": Move(.M, prime: true),
        "E'": Move(.E, prime: true),
        "S'": Move(.S, prime: true),
        
        "M2": Move(.M, twice: true),
        "E2": Move(.E, twice: true),
        "S2": Move(.S, twice: true),
    ]
}

extension Cube {
    // 回転処理
    // prime : 反時計回りかどうか
    // twice : 180°
    func apply(moveType: MoveType, prime: Bool = false, twice: Bool = false) -> Self {
        let predicated = moveType.filter
        let targetStickers = stickers.filter { predicated($0) }
        
        let angle: Rotation = twice ? .filp : prime ? .counterClockwire : .clockwise
        let moved = targetStickers.map { $0.rotate(on: moveType.axis, by: angle)}
        let notMoved = stickers.filter { !predicated($0) }
        
        var newCube = Cube()
        newCube.stickers = moved + notMoved
        return newCube
    }
    
    func apply(move: Move) -> Self {
        apply(moveType: move.moveType, prime: move.prime, twice: move.twice)
    }
    
    func apply(moves: [Move]) -> Self {
        moves.reduce(self, { $0.apply(move: $1) })
    }
    
    // スクランブル文字列
    // "U F F' B2 R2 L" のような一連の方向順番の文字列を対応できる
    func apply(movesStr: String) -> Self {
        apply(moves: Move.parse(movesStr))
    }
}
