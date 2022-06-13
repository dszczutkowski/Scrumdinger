//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Dave Szczutkowski on 09/06/2022.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScrumsView(scrums: DailyScrum.sampleData)
            }
        }
    }
}
