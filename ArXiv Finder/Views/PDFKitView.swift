import SwiftUI
import PDFKit

/// Renders a PDF from a local or remote URL.
///
/// The document is loaded on a background queue and assigned on the main thread, so a
/// large or remote PDF never blocks the UI (`PDFDocument(url:)` is synchronous and would
/// otherwise freeze the window while the file downloads).
#if os(macOS)
struct PDFKitView: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        context.coordinator.load(url: url, into: pdfView)
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        context.coordinator.load(url: url, into: pdfView)
    }
}
#else
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        context.coordinator.load(url: url, into: pdfView)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        context.coordinator.load(url: url, into: pdfView)
    }
}
#endif

extension PDFKitView {
    final class Coordinator {
        private var loadedURL: URL?

        /// Loads `url` asynchronously unless it is already shown.
        func load(url: URL, into pdfView: PDFView) {
            guard loadedURL != url else { return }
            loadedURL = url
            DispatchQueue.global(qos: .userInitiated).async {
                let document = PDFDocument(url: url)
                DispatchQueue.main.async {
                    // Only apply if the request is still current.
                    guard self.loadedURL == url else { return }
                    pdfView.document = document
                }
            }
        }
    }
}
