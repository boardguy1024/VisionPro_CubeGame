//
//  Cube2DView.swift
//  Cube
//
//  Created by paku on 2024/02/22.
//

import SwiftUI

struct Cube2DView: View {
    
    var cube2D = Cube2D()

    init(cube: Cube2D) {
        cube2D = cube
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            VStack {
                Grid {
                    GridRow {
                        Text("")
                        FaceCell(cube: cube2D, face: .up)
                    }
                    
                    GridRow {
                        FaceCell(cube: cube2D, face: .left)
                        FaceCell(cube: cube2D, face: .front)
                        FaceCell(cube: cube2D, face: .right)
                        FaceCell(cube: cube2D, face: .back)
                    }
                    
                    GridRow {
                        Text("")
                        FaceCell(cube: cube2D, face: .down)
                    }
                }
            }
        }
        
    }
}

struct FaceCell: View {
    let cube: Cube2D
    let face: Face
    
    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow {
                Cell(type: color(indexOfFace: 0))
                Cell(type: color(indexOfFace: 1))
                Cell(type: color(indexOfFace: 2))
            }
            
            GridRow {
                Cell(type: color(indexOfFace: 3))
                Cell(type: color(indexOfFace: 4))
                Cell(type: color(indexOfFace: 5))
            }
            
            GridRow {
                Cell(type: color(indexOfFace: 6))
                Cell(type: color(indexOfFace: 7))
                Cell(type: color(indexOfFace: 8))
            }
        }
    }
    
    func color(indexOfFace: Int) -> ColorType {
        // Cube2D init時に 0..<54のdefault色が収納されている
        // face: up, down, front, back, left, right順番
        // [w,w,w,w,w,w,w,w,w, r,r,r,r,r,r,r,r,r, g,g,g,g,g,g,g,g,g ...]
        cube.colors[face.rawValue * 9 + indexOfFace]
        
    }
}

struct Cell: View {
    let type: ColorType
    
    var body: some View {
        Rectangle()
            .fill(type.color)
            .frame(width: 20, height: 20 )
    }
}


#Preview {
    Cube2DView(cube: Cube().apply(move: .D).as2D())
}

struct Cube2D {
    
    var colors: [ColorType] = []
        
    init() {
        // colors.forEach { color * 1面に 9個のコマ }
        // 全部のコマ数は 54  colors = 6 * 1面のコマ数 = 9 == 54
        for color in ColorType.allCases {
            for _ in 0..<9 {
                colors.append(color)
            }
        }
    }

    mutating func setColorType(of face: Face, index: Int, color: ColorType) {
        colors[face.rawValue * 9 + index] = color
    }
}
