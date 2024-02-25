//
//  ContentView.swift
//  Cube
//
//  Created by paku on 2024/02/20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var cube = Cube()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            VStack {
                Cube2DView(cube: cube.as2D())
                MoveControllerView { move in
                    cube = cube.apply(move: move)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
