//
//  WorkTraceApp.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/6/25.
//

import AlertToast
import SwiftUI

enum ToastStatus: Equatable {
    case hide
    case error(title: String, subTitle: String? = nil)
    case success(title: String, subTitle: String? = nil)
    case warning(title: String, subTitle: String? = nil)
}

class AppViewModel: ObservableObject {
    @Published var globalToast: ToastStatus = .hide

    static let preview = AppViewModel()

    var homeViewModel = HomeViewModel(year: Date.now.year, month: Date.now.month)
}


@main
struct WorkTraceApp: App {
    @StateObject var appViewModel = AppViewModel()

    @State private var showErrorToast: Bool = false
    @State private var showSuccessToast: Bool = false
    @State private var showWarningToast: Bool = false

    var body: some Scene {
        WindowGroup {
            HomeView(vm: appViewModel.homeViewModel)
                .environmentObject(appViewModel)
                .preferredColorScheme(.light)
                .onChange(of: appViewModel.globalToast, perform: { newValue in
                    switch newValue {
                    case .hide:
                        showErrorToast = false
                        showSuccessToast = false
                        showWarningToast = false
                    case .error:
                        showErrorToast = true
                        showSuccessToast = false
                        showWarningToast = false
                    case .success:
                        showSuccessToast = true
                        showErrorToast = false
                        showWarningToast = false
                    case .warning:
                        showWarningToast = true
                        showErrorToast = false
                        showSuccessToast = false
                    }
                })
                .toast(isPresenting: $showErrorToast) {
                    AlertToast(displayMode: .hud,
                               type: .regular,
                               title: errorStatus.0,
                               style: .style(backgroundColor: .redStyle[1],
                                             titleColor: .white,
                                             subTitleColor: nil,
                                             titleFont: .system(size: 15, weight: .bold),
                                             subTitleFont: nil))
                }
                .toast(isPresenting: $showSuccessToast) {
                    AlertToast(displayMode: .hud,
                               type: .regular,
                               title: successStatus.0,
                               style: .style(backgroundColor: .greenStyle[1],
                                             titleColor: .white,
                                             subTitleColor: nil,
                                             titleFont: .system(size: 15, weight: .bold),
                                             subTitleFont: nil))
                }
                .toast(isPresenting: $showWarningToast) {
                    AlertToast(displayMode: .hud,
                               type: .regular,
                               title: warningStatus.0,
                               style: .style(backgroundColor: .blueStyle[1],
                                             titleColor: .white,
                                             subTitleColor: nil,
                                             titleFont: .system(size: 15, weight: .bold),
                                             subTitleFont: nil))
                }
        }
    }

    var errorStatus: (String, String?) {
        if case let .error(title, subTitle) = appViewModel.globalToast {
            return (title, subTitle)
        }
        return ("", "")
    }

    var successStatus: (String, String?) {
        if case let .success(title, subTitle) = appViewModel.globalToast {
            return (title, subTitle)
        }
        return ("", "")
    }

    var warningStatus: (String, String?) {
        if case let .warning(title, subTitle) = appViewModel.globalToast {
            return (title, subTitle)
        }
        return ("", "")
    }
}
