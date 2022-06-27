//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Dave Szczutkowski on 09/06/2022.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    ///The @StateObject property wrapper creates a single instance of an observable object for each instance of the structure that declares it.
    @StateObject private var store = ScrumStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScrumsView(scrums: $store.scrums) {
                    Task {
                        do {
                            try await ScrumStore.save(scrums: store.scrums)
                        } catch {
                            fatalError("Error saving scrums!")
                        }
                    }
                }
            }
            .task {
                do {
                    /// scrums is assigned a new value when the awaited function completes. Because scrums is a published property, any view observing ScrumStore refreshes when the property updates.
                    store.scrums = try await ScrumStore.load()
                } catch {
                    fatalError("Error loading scrums!")
                }
            }
        }
    }
}
