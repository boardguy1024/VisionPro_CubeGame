//
//  Cube2DView.swift
//  Cube
//
//  Created by paku on 2024/02/22.
//

import SwiftUI

struct Cube2DView: View {
    
    var cube2D = Cube2D()

    init(cube: Cube) {
        cube2D = cube.as2D()
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
                Cell(type: color(0))
                Cell(type: color(1))
                Cell(type: color(2))
            }
            
            GridRow {
                Cell(type: color(3))
                Cell(type: color(4))
                Cell(type: color(5))
            }
            
            GridRow {
                Cell(type: color(6))
                Cell(type: color(7))
                Cell(type: color(8))
            }
        }
    }
    
    func color(_ index: Int) -> ColorType {
        cube.color(of: face, index: index)
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
    Cube2DView(cube: Cube())
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
    
    private func index(of face: Face, index: Int) -> Int {
        /*
         case up = 0
         case down = 1
         case front = 2
         case back = 3
         case left = 4
         case right = 5
         */
    
        face.rawValue * 9 + index
    }
    
    func color(of face: Face, index: Int) -> ColorType {
    // index0 = white
    // index1 red
    // index2 green
    // index3 yellow
    // index4 orange
    // index5 blue
        return colors[self.index(of: face, index: index)]
    }
    
    mutating func setColorType(of face: Face, index: Int, color: ColorType) {
        colors[self.index(of: face, index: index)] = color
    }
}
