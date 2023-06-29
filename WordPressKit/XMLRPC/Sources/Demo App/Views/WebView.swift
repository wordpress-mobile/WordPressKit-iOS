import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    typealias NSViewType = WKWebView

    let string: String

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(string, baseURL: nil)
        webView.underPageBackgroundColor = .clear
        webView.enclosingScrollView?.backgroundColor = .purple
//
//        webView.evaluateJavaScript("document.readyState") { _, _ in
//            webView.invalidateIntrinsicContentSize()
//        }
    }
}
