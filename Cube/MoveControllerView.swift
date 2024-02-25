//
//  MoveControllerView.swift
//  Cube
//
//  Created by paku on 2024/02/25.
//

import SwiftUI

struct MoveControllerView: View {
    
    let buttonTapped: (Move) -> Void
    
    var body: some View {
        
        HStack {
            button("U")
            button("F")
            button("R")
            button("D")
            button("B")
            button("L")
        }
        .buttonStyle(.bordered)
    }
    
    func button(_ label: String) -> MoveButton {
        guard let move = Move.from(label) else {
            fatalError("Invalied move string")
        }
        return MoveButton(moveStr: label, action: { buttonTapped(move)})
    }
    
    struct MoveButton: View {
        let moveStr: String
        let action: () -> Void
        var body: some View {
            Button {
                action()
            } label: {
                Text(moveStr)
            }
            .keyboardShortcut(KeyEquivalent(moveStr.first!), modifiers: [])
        }
    }
}

#Preview {
    MoveControllerView(buttonTapped: { _ in })
}
