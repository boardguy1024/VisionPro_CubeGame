//
//  ContentView.swift
//  Cube
//
//  Created by paku on 2024/02/20.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @ObservedObject var play: Play

    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            VStack {
                HStack {
                    SceneView(scene: play.scene)
                        .frame(height: 200)
                }
                .padding(.bottom )
                Cube2DView(cube: play.cube.as2D())
                MoveControllerView(moves: $play.moves) { move in
                    play.apply(move: move)
                }
                .padding()
            }
        }
    }
}

//#Preview {
//    ContentView(cube: .constant(Cube()), moves: .constant([]))
//}
