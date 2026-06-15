//
//  PaperDetailView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Detailed view that shows all the information of a scientific paper
/// Destination screen when the user selects a paper from the list
///
/// Information displayed:
/// - Full title of the article
/// - Complete list of authors
/// - Publication and update dates
/// - Complete summary/abstract of the paper
/// - Scientific categories as badges
/// - Links to open the PDF and the article's web page
/// - Share actions (iOS) or contextual menus (macOS)
///
/// Navigation:
/// - iOS: Modal or push navigation with back button
/// - macOS: Detail panel in NavigationSplitView
/// - Action buttons adaptive to the platform
struct PaperDetailView: View {
    /// The article to display in detail
    let paper: ArXivPaper
    
    /// Controller to handle favorite logic
    let controller: ArXivController?
    
    /// Optional callback to return to the list (used in some navigation flows)
    let onBackToList: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewMode: ViewMode = .details

    /// Resolved URL used by the PDF viewer — a local cached file when available,
    /// otherwise the remote arXiv URL. Prepared when PDF mode is shown.
    @State private var resolvedPDFURL: URL?

    enum ViewMode: String, CaseIterable, Identifiable {
        case details = "Details"
        case pdf = "PDF"
        var id: String { self.rawValue }
    }

    var body: some View {
        Group {
            switch viewMode {
            case .pdf:
                if let url = resolvedPDFURL ?? URL(string: paper.pdfURL) {
                    PDFKitView(url: url)
                        .navigationTitle(paper.title)
                        #if os(macOS)
                        .navigationSubtitle("PDF View")
                        #else
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                        .task(id: paper.id) { await preparePDF() }
                } else {
                    ContentUnavailableView("PDF Unavailable", systemImage: "doc.text.slash")
                }
            case .details:
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                    // Paper title
                    Text(paper.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    // Author and date information
                    VStack(alignment: .leading, spacing: 8) {
                        Label(paper.authors, systemImage: "person.2")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                              systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Update date (if exists and is different)
                        if let updatedDate = paper.updatedDate,
                           abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // More than 1 hour difference
                            Label("Updated: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                                  systemImage: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Divider()
                    
                    // Paper categories
                    if !paper.categories.isEmpty {
                            let categories = paper.categories.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    
                    Divider()
                    
                    // Paper summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.headline)
                        
                        Text(paper.summary)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // Access links
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Links")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            if !paper.pdfURL.isEmpty {
                                Button(action: { viewMode = .pdf }) {
                                    HStack {
                                        Image(systemName: "doc.fill")
                                        Text("View PDF")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if let linkURL = URL(string: paper.linkURL) {
                                Link(destination: linkURL) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("View in ArXiv")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Paper Detail")
            #if os(macOS)
            .navigationSubtitle(paper.authors)
            .frame(minWidth: 400, minHeight: 300)
            #else
            .navigationBarTitleDisplayMode(.inline)
            #endif
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                // View Mode Picker
                if !paper.pdfURL.isEmpty {
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                
                // Toolbar items for PDF view
                if viewMode == .pdf, let url = URL(string: paper.pdfURL) {
                     Button(action: { downloadPDF(url: url) }) {
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                    
                    ShareLink(item: url)
                }
                
                // Favorite button for both platforms
                if let controller = controller {
                    Button(action: {
                        controller.toggleFavorite(for: paper)
                    }) {
                        Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(paper.isFavorite ? .red : .primary)
                    }
                    .help(paper.isFavorite ? "Remove from favorites" : "Add to favorites")
                }
                
                // Share link for details view if not in PDF mode
                if viewMode == .details, let url = URL(string: paper.pdfURL) {
                     ShareLink(item: url)
                }
            }
        }
    }
    
    /// Whether PDF caching is enabled in Settings (default on).
    private var cacheEnabled: Bool {
        UserDefaults.standard.object(forKey: "enableCache") as? Bool ?? true
    }

    /// Prepares the URL shown by the PDF viewer: a cached local file when available,
    /// otherwise the remote URL (downloaded and cached in the background for next time).
    private func preparePDF() async {
        if cacheEnabled, let cached = CacheManager.shared.getCachedPDF(for: paper.id) {
            resolvedPDFURL = cached
            return
        }

        guard let remote = URL(string: paper.pdfURL) else { return }
        resolvedPDFURL = remote

        guard cacheEnabled else { return }
        // Cache for offline/instant reuse without blocking the viewer.
        if let data = try? await Self.fetchValidatedPDF(from: remote),
           let local = try? CacheManager.shared.savePDF(data: data, for: paper.id) {
            resolvedPDFURL = local
        }
    }

    /// Downloads a PDF, validating the HTTP status and the `%PDF` magic bytes so a
    /// redirected HTML error page is never written/cached as a PDF.
    private static func fetchValidatedPDF(from url: URL) async throws -> Data {
        let (data, response) = try await ArXivService.session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        guard data.starts(with: [0x25, 0x50, 0x44, 0x46]) else { // "%PDF"
            throw URLError(.cannotParseResponse)
        }
        return data
    }

    /// Builds a filesystem-safe download filename from the paper title.
    private var downloadFileName: String {
        let invalid = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let base = paper.title.components(separatedBy: invalid).joined(separator: "-")
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.isEmpty ? "paper" : trimmed) + ".pdf"
    }

    private func downloadPDF(url: URL) {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = downloadFileName
        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                Task {
                    do {
                        let data = try await Self.fetchValidatedPDF(from: url)
                        try data.write(to: targetURL)
                        // Also cache it for in-app reuse.
                        _ = try? CacheManager.shared.savePDF(data: data, for: paper.id)
                    } catch {
                        print("Failed to download PDF: \(error)")
                    }
                }
            }
        }
        #else
        // iOS: ShareLink covers export; cache locally for offline viewing.
        Task {
            do {
                let data = try await Self.fetchValidatedPDF(from: url)
                _ = try? CacheManager.shared.savePDF(data: data, for: paper.id)
            } catch {
                print("Failed to cache PDF: \(error)")
            }
        }
        #endif
    }

    /// Determine the toolbar location according to the platform
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .automatic
        #else
        return .navigationBarTrailing
        #endif
    }
}

#Preview {
    NavigationView {
        PaperDetailView(
            paper: ArXivPaper(
                id: "2025.0001",
                title: "Example of ArXiv paper for Detail View",
                summary: "This is a more extensive example of a scientific paper that shows how it would look in the detail view of the application. It includes detailed technical information and multiple paragraphs to demonstrate the format.",
                authors: "John Doe, Jane Smith, Carlos López",
                publishedDate: Date(),
                updatedDate: Date(),
                pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
                linkURL: "https://arxiv.org/abs/2025.0001",
                categories: "cs.AI cs.LG stat.ML"
            ),
            controller: nil,
            onBackToList: nil
        )
    }
}
