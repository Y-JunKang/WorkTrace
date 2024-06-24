//
//  CustomAlert.swift
//  WorkTrace
//
//  Created by ByteDance on 2024/7/16.
//

import SwiftUI

struct CustomAlert: ViewModifier {
    @Binding var display: Bool
    var message: String
    var onDeterminate: () -> Void

    func body(content: Content) -> some View {
        content
        .alert(message, isPresented: $display) {
          Button("取消") {
            display.toggle()
          }
          
          Button("确定") {
            onDeterminate()
            display.toggle()
          }
        }
    }
}

extension View {
    func customAlert(display: Binding<Bool>, message: String, onDeterminate: @escaping () -> Void) -> some View {
        modifier(CustomAlert(display: display, message: message, onDeterminate: onDeterminate))
    }
}

