//
//  CacheManager.swift
//  ArXiv Finder
//
//  Created by ArXiv Finder Team on 3/7/25.
//

import Foundation

/// Manages the caching of PDF files for offline viewing.
///
/// All file operations are serialized behind a lock so the singleton can be used safely
/// from concurrent `Task`s while still exposing a synchronous API (needed by the PDF
/// `NSViewRepresentable`, which cannot `await`).
final class CacheManager: @unchecked Sendable {
    static let shared = CacheManager()

    private let fileManager = FileManager.default
    private let cacheDirectoryName = "PDFCache"
    private let lock = NSLock()

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
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("❌ CacheManager: Failed to create cache directory: \(error)")
            }
        }
    }

    /// Converts a paper id (which may be a full URL containing `/` and `:`) into a filename
    /// that is safe to use on disk.
    private func safeFileName(for id: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let sanitized = id.components(separatedBy: invalid).joined(separator: "-")
        return "\(sanitized).pdf"
    }

    /// Returns the local file URL for a cached PDF if it exists
    /// - Parameter id: The paper ID
    /// - Returns: Local URL if cached, nil otherwise
    func getCachedPDF(for id: String) -> URL? {
        lock.lock(); defer { lock.unlock() }
        guard let url = cacheDirectoryURL?.appendingPathComponent(safeFileName(for: id)) else { return nil }
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    /// Saves PDF data to the cache, enforcing the configured size limit afterwards.
    /// - Parameters:
    ///   - data: The PDF data
    ///   - id: The paper ID
    /// - Returns: The URL where the file was saved
    @discardableResult
    func savePDF(data: Data, for id: String) throws -> URL {
        lock.lock(); defer { lock.unlock() }
        guard let directory = cacheDirectoryURL else {
            throw NSError(domain: "CacheManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cache directory unavailable"])
        }

        let fileURL = directory.appendingPathComponent(safeFileName(for: id))
        try data.write(to: fileURL)
        enforceSizeLimitLocked()
        return fileURL
    }

    /// Clears all cached PDFs
    func clearCache() {
        lock.lock(); defer { lock.unlock() }
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
        lock.lock(); defer { lock.unlock() }
        return currentCacheSizeBytesLocked().map { Double($0) / (1024 * 1024) } ?? 0
    }

    // MARK: - Private helpers (must be called with `lock` held)

    private func currentCacheSizeBytesLocked() -> Int64? {
        guard let directory = cacheDirectoryURL else { return nil }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0
            for url in fileURLs {
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
                }
            }
            return totalSize
        } catch {
            print("❌ Error calculating cache size: \(error)")
            return nil
        }
    }

    /// Evicts the oldest cached PDFs until the cache is within the user-configured limit.
    private func enforceSizeLimitLocked() {
        guard let directory = cacheDirectoryURL else { return }

        // Default 100 MB if unset (matches the Settings default).
        let configuredLimit = UserDefaults.standard.integer(forKey: "cacheSizeLimit")
        let limitMB = configuredLimit == 0 ? 100 : configuredLimit
        let limitBytes = Int64(limitMB) * 1024 * 1024

        do {
            let keys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey]
            var files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: keys)
                .map { url -> (url: URL, size: Int64, date: Date) in
                    let values = try? url.resourceValues(forKeys: Set(keys))
                    return (url, Int64(values?.fileSize ?? 0), values?.contentModificationDate ?? .distantPast)
                }

            var totalSize = files.reduce(Int64(0)) { $0 + $1.size }
            guard totalSize > limitBytes else { return }

            // Oldest first.
            files.sort { $0.date < $1.date }
            for file in files {
                guard totalSize > limitBytes else { break }
                try? fileManager.removeItem(at: file.url)
                totalSize -= file.size
            }
            print("🧹 CacheManager: Evicted old PDFs to stay within \(limitMB) MB limit")
        } catch {
            print("❌ CacheManager: Error enforcing cache size limit: \(error)")
        }
    }
}
