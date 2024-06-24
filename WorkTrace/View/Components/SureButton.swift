//
//  SureButton.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/10/19.
//

import SwiftUI

struct SureButton: View {
    enum Size {
        case small
        case medium
        case large
    }

    var size: Size = .large
    var title: String
    var color: Color
    var onTap: () -> Void

    var vPadding: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 10
        case .large:
            return 14
        }
    }

    var hPadding: CGFloat {
        switch size {
        case .small:
            return 6
        case .medium:
            return 12
        case .large:
            return 20
        }
    }

    var radius: CGFloat {
        switch size {
        case .small:
            return 6
        case .medium:
            return 10
        case .large:
            return 16
        }
    }

    var font: Font {
        switch size {
        case .small:
            return .system(size: 12, weight: .bold)
        case .medium:
            return .system(size: 13, weight: .bold)
        case .large:
            return .system(size: 14, weight: .bold)
        }
    }

    var maxWidth: CGFloat {
        switch size {
        case .small:
            return 68
        case .medium:
            return 200
        case .large:
            return .infinity
        }
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(font)
            }
            .padding(.vertical, vPadding)
            .padding(.horizontal, hPadding)
            .frame(maxWidth: maxWidth)
            .background(color)
            .cornerRadius(radius)
        }
    }
}

struct SureButton_Previews: PreviewProvider {
    static var previews: some View {
        SureButton(title: "保存", color: Color.buttonGreen) {
        }

        SureButton(size: .medium, title: "保存", color: Color.buttonGreen) {
        }

        SureButton(size: .small, title: "保存", color: Color.buttonGreen) {
        }
    }
}
