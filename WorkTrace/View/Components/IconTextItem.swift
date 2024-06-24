//
//  IconTextItem.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import SwiftUI

struct IconText: View {
    var imageName: String
    var title: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: imageName)
                .frame(width: 24, height: 24)
            Text(title)
                .font(.system(size: 15, weight: .bold))
        }
        .foregroundColor(.purpleStyle[0])
    }
}

struct IconTextItem<Content: View>: View {
    var imageName: String
    var title: String

    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack {
            IconText(imageName: imageName, title: title)
            Spacer()

            content()
        }
    }
}

struct IconTextItem_Previews: PreviewProvider {
    static var previews: some View {
        IconTextItem(imageName: "calendar", title: "日期") {
            
        }
    }
}
