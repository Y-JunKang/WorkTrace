//
//  DottedLine.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/6/28.
//

import SwiftUI

struct DottedLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineJoin: .round, dash: [3, 3]))
        }
    }
}

struct DottedLine_Previews: PreviewProvider {
    static var previews: some View {
        DottedLine()
    }
}
