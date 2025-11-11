//
//  RestartView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct RestartView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .rotationEffect(.degrees(progress * 360))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: progress)
            
            Text("正在应用新语言设置...")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("当前语言: \(languageManager.getLanguageDisplayName())")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: progress)
                .frame(width: 200)
                .tint(.orange)
                .padding(.top, 10)
        }
        .padding()
        .onAppear {
            // 启动动画
            withAnimation {
                progress = 1.0
            }
            
            // 延迟2秒后重新加载应用
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // 重置重启标志
                NotificationCenter.default.post(name: NSNotification.Name("RestartCompleted"), object: nil)
                
                // 强制刷新所有视图
                NotificationCenter.default.post(name: NSNotification.Name("ForceRefreshViews"), object: nil)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    RestartView()
        .environmentObject(LanguageManager())
        .environmentObject(ThemeManager())
}