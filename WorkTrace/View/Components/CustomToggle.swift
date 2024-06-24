//
//  CustomToggle.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/10/26.
//

import SwiftUI

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(CustomToggleStyle())
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .foregroundColor(configuration.isOn ? Color(red: 0.96, green: 0.71, blue: 0.85) : Color(red: 0.92, green: 0.92, blue: 0.92))
            .frame(width: 39, height: 22, alignment: .center)
            .overlay(
                Circle()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.white)
                    .offset(x: configuration.isOn ? 8 : -8, y: 0)
                    .animation(.linear(duration: 0.3), value: configuration.isOn)
            ).cornerRadius(11)
            .onTapGesture { configuration.isOn.toggle() }
    }
}

struct CustomToggle_Previews: PreviewProvider {
    @State static var isOn = false

    static var previews: some View {
        CustomToggle(isOn: $isOn)
    }
}
