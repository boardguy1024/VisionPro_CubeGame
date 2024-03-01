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
    @StateObject var play = Play()
    var body: some Scene {
        WindowGroup {
            ContentView(play: play)
                .onChange(of: scenePhase) { _, newValue in
                    if newValue == .inactive {
                        do {
                            try play.save()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
                .task {
                    do {
                        try play.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
