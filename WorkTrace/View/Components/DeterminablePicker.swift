//
//  DeterminablePicker.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/10/19.
//

import SwiftUI

struct DeterminablePicker<Content: View>: View {
    @Binding var display: Bool
    var tips: String?
    var tipsAlignment: TextAlignment?
    @ViewBuilder var content: () -> Content
    var onDeterminate: () -> Bool

    var body: some View {
        VStack(spacing: 0) {
            if let tips = tips {
                VStack {
                    if case .leading = tipsAlignment {
                        HStack {
                            tipsText(tips: tips)

                            Spacer()
                        }
                    } else {
                        tipsText(tips: tips)
                    }
                    Spacer()
                }
                .frame(height: 60)
            }

            VStack {
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                SureButton(title: "取消", color: Color.redStyle[1]) {
                    withAnimation {
                        display.toggle()
                    }
                }

                SureButton(title: "确定", color: Color.buttonGreen) {
                    if onDeterminate() {
                        withAnimation {
                            display.toggle()
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.top, 20)
        .padding(.horizontal, 18)
    }

    func tipsText(tips: String) -> some View {
        Text(tips)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.secondaryTextColor)
            .multilineTextAlignment(.center)
    }
}

struct DeterminablePicker_Previews: PreviewProvider {
    static var previews: some View {
        DeterminablePicker(display: Binding.constant(true), tips: "测试室测试才实参哦测试室", tipsAlignment: .leading) {
            EmptyView()
        } onDeterminate: {
            true
        }
    }
}
