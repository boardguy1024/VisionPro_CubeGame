//
//  ContentView.swift
//  Cube
//
//  Created by paku on 2024/02/20.
//

import SwiftUI

struct ContentView: View {
    
     
    var body: some View {
        Cube2DView(cube: Cube().apply(move: .U).as2D())
    }
}


#Preview {
    ContentView()
}
