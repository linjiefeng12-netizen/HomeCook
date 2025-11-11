//
//  MainTabView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var id = UUID() // 添加ID用于强制刷新视图
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 使用id强制刷新整个视图
            Group {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text(LocalizedStrings.home)
                }
                .tag(0)
            
            FlavorGachaView()
                .tabItem {
                    Image(systemName: "dice")
                    Text(LocalizedStrings.flavorGacha)
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text(LocalizedStrings.profile)
                }
                .tag(3)
        }
        }
        .id(id) // 使用id强制刷新整个视图
        .accentColor(.orange)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
            // 收到刷新通知时更新ID，强制刷新视图
            self.id = UUID()
            print("MainTabView 收到强制刷新通知，已更新ID")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))) { _ in
            // 收到主题变化通知时更新ID，强制刷新视图
            self.id = UUID()
            print("MainTabView 收到主题变化通知，已更新ID")
        }
    }
}

#Preview {
    MainTabView()
}