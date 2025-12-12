//
//  CacheManager.swift
//  ArXiv Finder
//
//  Created by ArXiv Finder Team on 3/7/25.
//

import Foundation

/// Manages the caching of PDF files for offline viewing
class CacheManager {
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectoryName = "PDFCache"
    
    private var cacheDirectoryURL: URL? {
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return cacheDir.appendingPathComponent(cacheDirectoryName)
    }
    
    private init() {
        createCacheDirectoryIfNeeded()
    }
    
    /// Ensures the cache directory exists
    private func createCacheDirectoryIfNeeded() {
        guard let url = cacheDirectoryURL else { return }
        
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    /// Returns the local file URL for a cached PDF if it exists
    /// - Parameter id: The paper ID
    /// - Returns: Local URL if cached, nil otherwise
    func getCachedPDF(for id: String) -> URL? {
        guard let url = cacheDirectoryURL?.appendingPathComponent("\(id).pdf") else { return nil }
        
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }
    
    /// Saves PDF data to the cache
    /// - Parameters:
    ///   - data: The PDF data
    ///   - id: The paper ID
    /// - Returns: The URL where the file was saved
    func savePDF(data: Data, for id: String) throws -> URL {
        guard let directory = cacheDirectoryURL else {
            throw NSError(domain: "CacheManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cache directory unavailable"])
        }
        
        let fileURL = directory.appendingPathComponent("\(id).pdf")
        try data.write(to: fileURL)
        return fileURL
    }
    
    /// Clears all cached PDFs
    func clearCache() {
        guard let directory = cacheDirectoryURL else { return }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for url in fileURLs {
                try fileManager.removeItem(at: url)
            }
            print("✅ Cache cleared successfully")
        } catch {
            print("❌ Error clearing cache: \(error)")
        }
    }
    
    /// Calculates the current size of the cache in MB
    func getCacheSize() -> Double {
        guard let directory = cacheDirectoryURL else { return 0 }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0
            
            for url in fileURLs {
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
                }
            }
            
            // Convert bytes to MB
            return Double(totalSize) / (1024 * 1024)
        } catch {
            print("❌ Error calculating cache size: \(error)")
            return 0
        }
    }
}
