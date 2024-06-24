//
//  NavBar.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/10/15.
//

import SwiftUI

extension ToolBar where Content1 == Text {
    init(title: String, leadingItemBuilder: @escaping () -> Content2, trailingItemBuilder: @escaping () -> Content3) {
        titleBuilder = {
            Text(title)
        }
        self.leadingItemBuilder = leadingItemBuilder
        self.trailingItemBuilder = trailingItemBuilder
    }
}

struct ToolBar<Content1: View, Content2: View, Content3: View>: View {
    @ViewBuilder var titleBuilder: () -> Content1
    @ViewBuilder var leadingItemBuilder: () -> Content2
    @ViewBuilder var trailingItemBuilder: () -> Content3

    init(titleBuilder: @escaping () -> Content1, leadingItemBuilder: @escaping () -> Content2, trailingItemBuilder: @escaping () -> Content3) {
        self.titleBuilder = titleBuilder
        self.leadingItemBuilder = leadingItemBuilder
        self.trailingItemBuilder = trailingItemBuilder
    }

    var body: some View {
        HStack(alignment: .center) {
            AnyView(leadingItemBuilder())

            Spacer()

            AnyView(trailingItemBuilder())
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .overlay(content: {
            titleBuilder()
        })
        .background(Color.white)
        .foregroundColor(.purpleStyle[0])
        .font(.system(size: 15, weight: .bold))
    }
}

struct TitleTappableToolBar<Content1: View, Content2: View>: View {
    var title: String
    @ViewBuilder var leadingItemBuilder: () -> Content1
    @ViewBuilder var trailingItemBuilder: () -> Content2
    var onTap: () -> Void

    var body: some View {
        ToolBar {
            HStack {
                Text(title)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
            }
            .onTapGesture {
                onTap()
            }
        } leadingItemBuilder: {
            leadingItemBuilder()
        } trailingItemBuilder: {
            trailingItemBuilder()
        }
    }
}

struct NavBar<Content: View>: View {
    var title: String
    @ViewBuilder var trailingItemBuilder: () -> Content
    var onBackTap: () -> Void

    var body: some View {
        ToolBar(title: title) {
            Button {
                onBackTap()
            } label: {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.purpleStyle[0])
            }
        } trailingItemBuilder: {
            trailingItemBuilder()
        }
    }
}

struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NavBar(title: "添加倒计时") {
                Button {
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            } onBackTap: {
                print("back ")
            }
        }
        .environmentObject(AppViewModel.preview)
    }
}
