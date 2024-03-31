//
//  Debugging.swift
//  Transcopied
//
//  Created by Dakota Lorance on 3/19/24.
//

import SwiftUI

extension Color {
    /// Returns a random RGB Color value
    static var random: Color {
        get {
            return Color(
                red: Double.random(in: 0.1..<0.95),
                green: Double.random(in: 0.1..<0.95),
                blue: Double.random(in: 0.1..<0.95)
            )
        }
    }
}

extension View {
    func debugModifier(_ modifier: (Self) -> some View) -> some View {
#if DEBUG
        return modifier(self)
#else
        return self
#endif
    }
}

extension View {
    func debugBorder(_ color: Color = Color.random, width: CGFloat = 1, opacity: Double = 1.0) -> some View {
        debugModifier {
            $0.border(color.opacity(opacity), width: width)
//                .border(cornerRadius: 0.0, style: StrokeStyle(lineWidth: width*(dashed ? 1.5:0), dash: [10, 10]))
        }
    }
    func debugBackground(_ color: Color = .random, opacity: Double = 0.7) -> some View {
        debugModifier {
            $0.background(color.opacity(opacity))
        }
    }
}

#Preview {
    Group {
        HStack(alignment: .firstTextBaseline) {
            Text("Test")
                .debugBorder(.black)
                .debugBackground(.green)
        }
        .padding()
        .debugBorder(.black)
        .debugBackground(.magenta)
    }
}
