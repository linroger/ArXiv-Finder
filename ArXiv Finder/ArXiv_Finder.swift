//
//  ArXiv_Finder.swift
//  ArXiv Finder
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/**
 * ARXIV FINDER APPLICATION ARCHITECTURE
 * =====================================
 * 
 * This application follows the Model-View-Controller (MVC) pattern:
 * 
 * MODELS (Models):
 * - ArXivPaper: Data model for scientific papers with SwiftData
 * 
 * VIEWS (Views):
 * - MainView: Main view that coordinates navigation
 * - SidebarView: Sidebar for macOS
 * - PapersListView: Paper list with multiplatform adaptations
 * - ArXivPaperRow: Individual paper row
 * - PaperDetailView: Complete detail of a paper
 * 
 * CONTROLLERS (Controllers):
 * - ArXivController: Business logic and state management
 * 
 * SERVICES (Services):
 * - ArXivService: Communication with the ArXiv API
 * - ArXivSimpleParser: Custom XML parser
 * 
 * TECHNICAL FEATURES:
 * - Multiplatform: iOS and macOS with adaptive UI
 * - Persistence: SwiftData for local storage
 * - Networking: URLSession with robust error handling
 * - UI: SwiftUI with NavigationStack (iOS) and NavigationSplitView (macOS)
 * - Concurrency: async/await with @MainActor for UI updates
 */

/// Main entry point of the ArXiv Finder application
/// Configures the application, data persistence and platform-specific UI
/// 
/// Responsibilities:
/// - SwiftData container configuration for persistence
/// - Platform-specific window structure definition
/// - Data model injection into SwiftUI environment
/// - Specific window configuration (macOS: size, style; iOS: basic group)
@main
struct ArXiv_Finder: App {
    /// Observe the accent color setting to apply it globally
    @AppStorage("accentColor") private var accentColorName = "Blue"
    
    /// Convert the stored string name to a SwiftUI Color
    private var accentColor: Color {
        switch accentColorName {
        case "Red": return .red
        case "Orange": return .orange
        case "Green": return .green
        case "Purple": return .purple
        default: return .blue
        }
    }

    /// Shared model container that manages application persistence
    /// Configured with SwiftData to handle local storage of ArXiv papers
    var sharedModelContainer: ModelContainer = {
        // Define the data schema that includes all application models
        let schema = Schema([
            ArXivPaper.self, // Model for ArXiv papers
        ])
        
        // Configure the model to use persistent storage (not in memory)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // Try to create the model container with the specified configuration
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("❌ SwiftData Error: \(error)")
            
            // If the error is related to migration issues, try to delete the store and recreate
            if error.localizedDescription.contains("migration") || 
               error.localizedDescription.contains("constraint violation") ||
               error.localizedDescription.contains("loadIssueModelContainer") {
                
                print("🔄 Attempting to recover from SwiftData migration error...")
                
                // Try to delete the existing store files
                let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
                try? FileManager.default.removeItem(at: storeURL)
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
                
                print("🗑️ Deleted existing store files")
                
                // Try to create a new container
                do {
                    let newContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
                    print("✅ Successfully created new ModelContainer after recovery")
                    return newContainer
                } catch {
                    print("❌ Failed to create new container after recovery: \(error)")
                }
            }

            // Last resort: fall back to an in-memory store so the app still launches
            // (favorites won't persist this session, but the user is not locked out).
            print("⚠️ Falling back to an in-memory store for this session.")
            do {
                let memoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [memoryConfiguration])
            } catch {
                fatalError("Could not create ModelContainer (including in-memory fallback): \(error)")
            }
        }
    }()

    /// Defines the main structure of the application user interface
    /// Uses platform-specific configurations for each platform (iOS/macOS)
    var body: some Scene {
        #if os(macOS)
        // macOS-specific configuration with resizable window
        WindowGroup {
            MainView()
                .frame(minWidth: 1080, minHeight: 640)
                .tint(accentColor)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1320, height: 820)
        // Inject the shared model container into the SwiftUI environment
        // This allows all views to access persistent data
        .modelContainer(sharedModelContainer)
        
        // Additional configuration for macOS
        Settings {
            SettingsView()
                .tint(accentColor)
        }
        #else
        // iOS-specific configuration
        WindowGroup {
            MainView()
                .tint(accentColor)
        }
        // Inject the shared model container into the SwiftUI environment
        // This allows all views to access persistent data
        .modelContainer(sharedModelContainer)
        #endif
    }
    
    // Additional initializers for handling migration or custom setup could be added here
    init() {
        // App-wide initialization
        // E.g. Theme setup, global styles
    }
} 