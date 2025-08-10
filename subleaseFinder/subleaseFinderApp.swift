//
//  subleaseFinderApp.swift
//  subleaseFinder
//
//  Created by Lya Mun on 6/4/25.
//

import SwiftUI

#if canImport(Firebase)
import Firebase
#endif

@main
struct subleaseFinderApp: App {
    init() {
        #if canImport(Firebase)
        // Configure Firebase if available
        FirebaseApp.configure()
        #else
        // Firebase not available - using mock services
        print("Firebase not available - using mock authentication")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
