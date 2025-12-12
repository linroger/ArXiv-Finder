//
//  SidebarView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Sidebar navigation designed specifically for macOS
/// Part of the NavigationSplitView that provides main navigation
///
/// Features:
/// - Main navigation by ArXiv categories
/// - Visual indicators of the currently selected category
/// - Header with branding of the application
/// - Sections organized by content type
/// - Asynchronous callbacks to load data for each category
/// - Placeholders for future features (Favorites, Search)
///
/// Design:
/// - System macOS colors for native integration
/// - SF Symbols icons for visual consistency
/// - Optimized spacing and typography for desktop
struct SidebarView: View {
    /// Currently selected category
    @Binding var currentCategory: String
    
    /// Callback to load the latest papers
    let onLatestPapersSelected: () async -> Void
    
    /// Callback to load Computer Science papers
    let onComputerScienceSelected: () async -> Void
    
    /// Callback to load Mathematics papers
    let onMathematicsSelected: () async -> Void
    
    /// Callback to load Physics papers
    let onPhysicsSelected: () async -> Void
    
    /// Callback to load Quantitative Biology papers
    let onQuantitativeBiologySelected: () async -> Void
    
    /// Callback to load Quantitative Finance papers
    let onQuantitativeFinanceSelected: () async -> Void
    
    /// Callback to load Statistics papers
    let onStatisticsSelected: () async -> Void
    
    /// Callback to load Electrical Engineering papers
    let onElectricalEngineeringSelected: () async -> Void
    
    /// Callback to load Economics papers
    let onEconomicsSelected: () async -> Void
    
    /// Callback to load favorite papers
    let onFavoritesSelected: () async -> Void
    
    /// Callback to open search view
    let onSearchSelected: () async -> Void
    
    var body: some View {
        List {
            Section("Library") {
                sidebarButton(
                    title: "Latest Papers",
                    icon: "doc.text",
                    isSelected: currentCategory == "latest"
                ) {
                    Task { await onLatestPapersSelected() }
                }
                
                sidebarButton(
                    title: "Favorites",
                    icon: "heart.fill",
                    isSelected: currentCategory == "favorites"
                ) {
                    Task { await onFavoritesSelected() }
                }
            }
            
            Section("Categories") {
                sidebarButton(
                    title: "Computer Science",
                    icon: "laptopcomputer",
                    isSelected: currentCategory == "cs"
                ) {
                    Task { await onComputerScienceSelected() }
                }
                
                sidebarButton(
                    title: "Mathematics",
                    icon: "x.squareroot",
                    isSelected: currentCategory == "math"
                ) {
                    Task { await onMathematicsSelected() }
                }
                
                sidebarButton(
                    title: "Physics",
                    icon: "atom",
                    isSelected: currentCategory == "physics"
                ) {
                    Task { await onPhysicsSelected() }
                }
                
                sidebarButton(
                    title: "Quantitative Biology",
                    icon: "leaf",
                    isSelected: currentCategory == "q-bio"
                ) {
                    Task { await onQuantitativeBiologySelected() }
                }
                
                sidebarButton(
                    title: "Quantitative Finance",
                    icon: "chart.line.uptrend.xyaxis",
                    isSelected: currentCategory == "q-fin"
                ) {
                    Task { await onQuantitativeFinanceSelected() }
                }
                
                sidebarButton(
                    title: "Statistics",
                    icon: "chart.bar",
                    isSelected: currentCategory == "stat"
                ) {
                    Task { await onStatisticsSelected() }
                }
                
                sidebarButton(
                    title: "Electrical Engineering",
                    icon: "bolt",
                    isSelected: currentCategory == "eess"
                ) {
                    Task { await onElectricalEngineeringSelected() }
                }
                
                sidebarButton(
                    title: "Economics",
                    icon: "dollarsign.circle",
                    isSelected: currentCategory == "econ"
                ) {
                    Task { await onEconomicsSelected() }
                }
            }
            
            Section("Tools") {
                sidebarButton(
                    title: "Search",
                    icon: "magnifyingglass",
                    isSelected: currentCategory == "search"
                ) {
                    Task { await onSearchSelected() }
                }
            }
        }
        .listStyle(SidebarListStyle())
        #if os(macOS)
        .frame(minWidth: 200)
        #endif
    }
    
    /// Create a custom button for the sidebar
    /// Handles the visual state (selected/not selected) and enabled/disabled
    /// 
    /// - Parameters:
    ///   - title: Text of the button
    ///   - icon: Name of the SF Symbols icon
    ///   - isSelected: If the button is currently selected
    ///   - isEnabled: If the button is enabled (default true)
    ///   - action: Action to execute when the button is pressed
    /// - Returns: Configured button view
    @ViewBuilder
    private func sidebarButton(
        title: String,
        icon: String,
        isSelected: Bool,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
        .tag(title) // Important for selection in List
    }
}

#Preview {
    SidebarView(
        currentCategory: .constant("latest"),
        onLatestPapersSelected: { },
        onComputerScienceSelected: { },
        onMathematicsSelected: { },
        onPhysicsSelected: { },
        onQuantitativeBiologySelected: { },
        onQuantitativeFinanceSelected: { },
        onStatisticsSelected: { },
        onElectricalEngineeringSelected: { },
        onEconomicsSelected: { },
        onFavoritesSelected: { },
        onSearchSelected: { }
    )
    .frame(width: 320, height: 600)
}
