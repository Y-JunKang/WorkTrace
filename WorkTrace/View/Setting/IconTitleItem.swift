//
//  IconTitleItem.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/10/17.
//

import SwiftUI

struct IconTitleItem<Content: View>: View {
    enum ArrowState {
        case show
        case hidden
        case gone
    }

    var imageName: String
    var title: String
    var showArrow = ArrowState.show
    var content: () -> Content

    var body: some View {
        HStack {
            IconText(imageName: imageName, title: title)
            Spacer()

            content()

            switch showArrow {
            case .show:
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .frame(width: 12, height: 12)
                    .foregroundColor(.purpleStyle[0])
            case .hidden:
                Color.clear
                    .frame(width: 12, height: 12)
            case .gone:
                EmptyView()
            }
        }
        .padding(.vertical, 8)
    }
}

struct IconTitleNoteItem: View {
    var imageName: String
    var title: String
    var note: String

    var body: some View {
        IconTitleItem(imageName: imageName, title: title) {
            Text(note)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.purpleStyle[2])
        }
    }
}

struct IconTitleEmptyItem: View {
    var imageName: String
    var title: String

    var body: some View {
        IconTitleItem(imageName: imageName, title: title) {
            EmptyView()
        }
    }
}

struct TappableItem_Previews: PreviewProvider {
    static var previews: some View {
        IconTitleEmptyItem(imageName: "clock", title: "闹钟")
        IconTitleNoteItem(imageName: "clock", title: "闹钟", note: "1月21号")
    }
}
