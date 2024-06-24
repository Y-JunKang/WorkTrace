//
//  AppViewModel.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import Foundation

enum ToastStatus: Equatable {
    case hide
    case error(title: String, subTitle: String? = nil)
    case success(title: String, subTitle: String? = nil)
    case warning(title: String, subTitle: String? = nil)
}

class AppViewModel: ObservableObject {
    @Published var globalToast: ToastStatus = .hide

    static let inst = AppViewModel()
    static let debug = AppViewModel()

    var homeViewModel = HomeViewModel(year: Date.now.year(), month: Date.now.month())
}
