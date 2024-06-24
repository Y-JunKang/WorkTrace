//
//  StatusView.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import SwiftUI

struct StatusView: View {
    var message: String
    var onTap: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.purpleStyle[4])
            .frame(minHeight: 120)
            .overlay(alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    Button {
                        onTap()
                    } label: {
                        Rectangle()
                            .frame(width: 40, height: 40)
                            .cornerRadius(16)
                            .foregroundColor(.purpleStyle[3])
                            .overlay(alignment: .center) {
                                Image(systemName: "plus")
                                    .frame(width: 22, height: 22)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.purpleStyle[0])
                            }
                    }

                    Text(message)
                        .foregroundColor(.purpleStyle[2])
                        .font(.system(size: 14, weight: .medium))
                        .padding(.top, 12)
                }
            }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(message: "还没有添加任何倒计时") {
        }
    }
}
