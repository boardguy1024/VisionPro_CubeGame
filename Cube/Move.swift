//
//  Move.swift
//  Cube
//
//  Created by paku on 2024/02/23.
//

import SwiftUI

enum MoveType: Character, CaseIterable {
    
    case U = "U" // upの面
    case D = "D" // down面
    case L = "L"
    case F = "F" // frontの面
    case R = "R" // rightの面　 x軸を中心に回る(縦回り）
    case B = "B"
    case x = "x"
    case y = "y"
    case z = "z"
    
    var axis: Vector {
        switch self {
        case .U: Axis.Y
        case .D: Axis.Y.negative
        case .L: Axis.X.negative
        case .F: Axis.Z
        case .R: Axis.X
        case .B: Axis.Z.negative
        
        case .x: Axis.X
        case .y: Axis.Y
        case .z: Axis.Z
        }
    }
    
    var filter: (Sticker) -> Bool {
        switch self {
        case .U: return { $0.position.y > 0 }
        case .D: return { $0.position.y < 0 }
        case .L: return { $0.position.x < 0 }
        case .F: return { $0.position.z > 0 }
        case .R: return { $0.position.x > 0 }
        case .B: return { $0.position.z < 0 }
        case .x: return { _ in true }
        case .y: return { _ in true }
        case .z: return { _ in true }
        }
    }
}

struct Move {
    let moveType: MoveType
    let prime: Bool
    let twice: Bool
    
    init(_ moveType: MoveType, prime: Bool = false, twice: Bool = false ) {
        self.moveType = moveType
        self.prime = prime
        self.twice = twice
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
