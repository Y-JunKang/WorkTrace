//
//  RoundedArea.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import SwiftUI

struct RoundedArea<Content: View>: View {
    var backgroundColor: Color

    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 8) {
            content()
        }
        .padding(8)
        .background(backgroundColor)
        .cornerRadius(8)
        .frame(minHeight: 32)
    }
}

struct RoundedArea_Previews: PreviewProvider {
    static var previews: some View {
        RoundedArea(backgroundColor: .purpleStyle[3]) {
            Text("content here")
        }
        .foregroundColor(.purpleStyle[0])
    }
}
