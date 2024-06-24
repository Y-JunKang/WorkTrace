//
//  WebViewPage.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/10/30.
//

import AlertToast
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    @Binding var loading: Bool

    // Assign custom coordinator for delegate functions.
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.loading = false
        }
    }
}

struct WebViewPage: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var title: String
    var url: String

    @State private var loading = true

    var body: some View {
        VStack {
            NavBar(title: title) {
            } onBackTap: {
            }

            WebView(url: URL(string: url)!, loading: $loading)
                .overlay {
                    if loading {
                        AlertToast(displayMode: .alert, type: .loading)
                    }
                }
        }
        .navigationBarHidden(true)
    }
}
