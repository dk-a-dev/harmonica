//
//  InAppWebView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI
import WebKit

#if os(iOS)
struct InAppWebView: View {
    let url: URL
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var progress: Double = 0
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = true
    @State private var webViewStore = WebViewStore()
    
    var body: some View {
        let theme = themeManager.current
        
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                if isLoading {
                    ProgressView(value: progress)
                        .tint(theme.accent)
                        .frame(height: 3)
                }
                
                WebViewWrapper(
                    url: url,
                    store: webViewStore,
                    title: $title,
                    progress: $progress,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    isLoading: $isLoading
                )
                .ignoresSafeArea(edges: .bottom)
                
                // Bottom browser toolbar
                HStack(spacing: 0) {
                    Group {
                        Button(action: { webViewStore.webView?.goBack() }) {
                            Image(systemName: "chevron.left")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(!canGoBack)
                        
                        Button(action: { webViewStore.webView?.goForward() }) {
                            Image(systemName: "chevron.right")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(!canGoForward)
                        
                        Button(action: { webViewStore.webView?.reload() }) {
                            Image(systemName: isLoading ? "xmark" : "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            let av = UIActivityViewController(
                                activityItems: [url],
                                applicationActivities: nil
                            )
                            UIApplication.shared.firstKeyWindow?
                                .rootViewController?
                                .present(av, animated: true)
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: { UIApplication.shared.open(url) }) {
                            Image(systemName: "safari")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundColor(theme.accent)
                    .frame(height: 44)
                }
                .background(theme.surface)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(theme.secondaryText.opacity(0.3)),
                    alignment: .top
                )
            }
            .navigationTitle(title.isEmpty ? (url.host ?? "") : title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.accent)
                }
            }
        }
    }
}

// Holds WKWebView instance so it persists
class WebViewStore {
    var webView: WKWebView?
}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    let store: WebViewStore
    @Binding var title: String
    @Binding var progress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // KVO observers
        webView.addObserver(
            context.coordinator,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new, context: nil
        )
        webView.addObserver(
            context.coordinator,
            forKeyPath: #keyPath(WKWebView.title),
            options: .new, context: nil
        )
        webView.addObserver(
            context.coordinator,
            forKeyPath: #keyPath(WKWebView.canGoBack),
            options: .new, context: nil
        )
        webView.addObserver(
            context.coordinator,
            forKeyPath: #keyPath(WKWebView.canGoForward),
            options: .new, context: nil
        )
        
        store.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let webView = object as? WKWebView else { return }
            
            DispatchQueue.main.async {
                switch keyPath {
                case #keyPath(WKWebView.estimatedProgress):
                    self.parent.progress = webView.estimatedProgress
                case #keyPath(WKWebView.title):
                    self.parent.title = webView.title ?? ""
                case #keyPath(WKWebView.canGoBack):
                    self.parent.canGoBack = webView.canGoBack
                case #keyPath(WKWebView.canGoForward):
                    self.parent.canGoForward = webView.canGoForward
                default:
                    break
                }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.parent.title = webView.title ?? ""
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

#else
// macOS fallback — just opens in Safari
struct InAppWebView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Opening in browser...")
            Button("Dismiss") { dismiss() }
        }
        .onAppear {
            NSWorkspace.shared.open(url)
            dismiss()
        }
    }
}
#endif

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
