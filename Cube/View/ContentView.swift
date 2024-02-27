//
//  ContentView.swift
//  Cube
//
//  Created by paku on 2024/02/20.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @Binding var cube: Cube
    @Binding var moves: [Move]
 
    var cube3D: Cube3D = Cube3D(with: Cube())
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            VStack {
                HStack {
                    SceneView(scene: cube3D.scene)
                        .frame(height: 200)
                }
                .padding(.bottom )
                Cube2DView(cube: cube.as2D())
                MoveControllerView(moves: $moves) { move in
                    cube = cube.apply(move: move)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView(cube: .constant(Cube()), moves: .constant([]))
}
