//
//  CubeApp.swift
//  Cube
//
//  Created by paku on 2024/02/20.
//

import SwiftUI

@main
struct CubeApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            ContentView(cube: $dataStore.cube, moves: $dataStore.moves)
                .onChange(of: scenePhase) { _, newValue in
                    if newValue == .inactive {
                        do {
                            try dataStore.save()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
                .task {
                    do {
                        try dataStore.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
