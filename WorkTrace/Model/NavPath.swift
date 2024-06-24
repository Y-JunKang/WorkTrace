//
//  NavPath.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import Foundation

enum NavPath: Hashable {
    static func == (lhs: NavPath, rhs: NavPath) -> Bool {
        return lhs.description() == rhs.description()
    }

    case home
    case monthList
    case setting
    case webview(title: String, url: String)

    func description() -> String {
        switch self {
        case .home:
            return "home"
        case .monthList:
            return "monthList"
        case .setting:
            return "setting"
        case .webview:
            return "webview"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(description())
    }
}
