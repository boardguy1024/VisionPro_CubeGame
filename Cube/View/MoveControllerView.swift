//
//  MoveControllerView.swift
//  Cube
//
//  Created by paku on 2024/02/25.
//

import SwiftUI

struct MoveControllerView: View {
    enum Layout {
        case vertical, horizontal
    }
    
    @Binding var moves: [Move]

    let buttonTapped: (Move) -> Void
    
    var body: some View {
        
        HStack {
            VStack {
                rotateButtons
                Divider().frame(width: 120)
                extraButtons
            }
            
            Spacer()
            
            VStack {
                turnButtons
                Divider().frame(width: 80)
                Button("Undo") {
                    undo()
                }
                .disabled(moves.isEmpty)
            }
            
        }
        .buttonStyle(.bordered)
        .padding()
    }
    
    func undo() {
        if let move = moves.popLast() {
            buttonTapped(move.reversed)
        }
    }
    
    func button(_ label: String, prime: Bool = false) -> MoveButton {
        let label = prime ? "\(label)'" : label
        guard let move = Move.from(label) else {
            fatalError("Invalied move string")
        }
        return MoveButton(moveStr: label, action: {
            self.moves.append(move)
            buttonTapped(move)
        })
    }
    
    struct MoveButton: View {
        let moveStr: String
        let action: () -> Void
        
        var isPrime: Bool {
            moveStr.hasSuffix("'")
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(moveStr)
            }
            .keyboardShortcut(KeyEquivalent(moveStr.first!), modifiers: isPrime ? [.shift] : [])
        }
    }
    
    func pair(_ label: String, layout: Layout, primeFirst: Bool) -> some View {
        HStack {
            if layout == .vertical {
                VStack {
                    if primeFirst {
                        button(label, prime: true)
                    }
                    button(label)
                    if !primeFirst {
                        button(label, prime: true)
                    }
                }
            } else {
                if primeFirst {
                    button(label, prime: true)
                }
                button(label)
                if !primeFirst {
                    button(label, prime: true)
                }
            }
        }
    }
    
    var turnButtons: some View {
        VStack {
            HStack {
                pair("L", layout: .vertical, primeFirst: false)
                VStack {
                    pair("U", layout: .horizontal, primeFirst: true)
                    pair("F", layout: .horizontal, primeFirst: true)
                    pair("D", layout: .horizontal, primeFirst: false)
                }
                pair("R", layout: .vertical, primeFirst: true)
            }
            Divider().frame(width:80)
            pair("B", layout: .horizontal, primeFirst: false)
        }
    }

    var extraButtons: some View {
        HStack {
            pair("E", layout: .vertical, primeFirst: false)
            pair("M", layout: .vertical, primeFirst: false)
            pair("S", layout: .vertical, primeFirst: false)
        }
    }

    var rotateButtons: some View {
        HStack {
            pair("z", layout: .vertical, primeFirst: false)
            Divider().frame(height:80)
            VStack {
                button("x", prime: false)
                pair("y", layout: .horizontal, primeFirst: false)
                button("x", prime: true)
            }
        }
    }
}

//#Preview {
//    MoveControllerView(buttonTapped: { _ in })
//}
