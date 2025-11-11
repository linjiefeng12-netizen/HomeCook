//
//  ContentView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
