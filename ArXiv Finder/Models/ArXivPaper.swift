//
//  ArXivPaper.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftData

/// Data model representing a scientific paper from ArXiv
/// Stores the main information of each paper for offline access
@Model
final class ArXivPaper {
    /// Unique identifier of the paper in ArXiv (e.g.: "2023.12345v1")
    @Attribute(.unique) var id: String
    
    /// Complete title of the scientific paper
    var title: String
    
    /// Abstract or summary of the paper
    var summary: String
    
    /// List of paper authors, comma-separated
    var authors: String
    
    /// Publication date of the paper
    var publishedDate: Date
    
    /// Last update date of the paper (if available)
    var updatedDate: Date?
    
    /// PDF URL of the paper on ArXiv
    var pdfURL: String
    
    /// Web page URL of the paper on ArXiv
    var linkURL: String
    
    /// Scientific categories of the paper (e.g.: "cs.AI", "math.CO")
    var categories: String
    
    /// Number of citations (mocked for demonstration as ArXiv API doesn't provide this)
    var citationCount: Int
    
    /// Indicates if the paper is marked as favorite
    var isFavorite: Bool = false
    
    /// Date when marked as favorite (only relevant if isFavorite is true)
    var favoritedDate: Date?
    
    /// Main initializer for creating a new ArXiv paper
    /// - Parameters:
    ///   - id: Unique identifier of the paper
    ///   - title: Title of the paper
    ///   - summary: Summary of the paper
    ///   - authors: Authors of the paper
    ///   - publishedDate: Publication date
    ///   - updatedDate: Last update date (optional)
    ///   - pdfURL: PDF URL
    ///   - linkURL: Paper page URL
    ///   - categories: Scientific categories
    ///   - citationCount: Number of citations (optional, default random)
    ///   - isFavorite: If marked as favorite (default false)
    init(id: String, title: String, summary: String, authors: String, 
         publishedDate: Date, updatedDate: Date? = nil, pdfURL: String, linkURL: String, categories: String, citationCount: Int? = nil, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.summary = summary
        self.authors = authors
        self.publishedDate = publishedDate
        self.updatedDate = updatedDate
        self.pdfURL = pdfURL
        self.linkURL = linkURL
        self.categories = categories
        // arXiv does not expose citation counts. We show a *deterministic* illustrative
        // value derived from the paper id so the number is stable across fetches and app
        // launches (sorting by citations no longer reshuffles on every refresh).
        self.citationCount = citationCount ?? ArXivPaper.illustrativeCitationCount(for: id)
        self.isFavorite = isFavorite
        self.favoritedDate = isFavorite ? Date() : nil
    }

    /// Deterministic, launch-stable placeholder citation count in 0...500 derived from the
    /// paper id using a djb2 hash (Swift's `hashValue` is per-launch seeded and unsuitable).
    static func illustrativeCitationCount(for id: String) -> Int {
        var hash: UInt64 = 5381
        for byte in id.utf8 {
            hash = (hash &* 33) &+ UInt64(byte)
        }
        return Int(hash % 501)
    }

    /// Marks or unmarks the paper as favorite
    /// - Parameter favorite: true to mark as favorite, false to unmark
    func setFavorite(_ favorite: Bool) {
        self.isFavorite = favorite
        self.favoritedDate = favorite ? Date() : nil
    }
}
