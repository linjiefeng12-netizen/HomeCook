//
//  WelcomeView.swift
//  HomeCook
//
//  Created by CodeBuddy on 2025/1/8.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isAnimating = false
    @State private var showMainView = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.1),
                    Color.orange.opacity(0.05),
                    Color(.systemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 主标题和图标
                VStack(spacing: 24) {
                    // 应用图标
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.orange,
                                        Color.orange.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.orange.opacity(0.3), radius: 20, x: 0, y: 10)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        Image(systemName: "fork.knife")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // 应用标题
                    Text("HomeCook")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(opacity)
                        .scaleEffect(scale)
                    
                    // 副标题
                    Text(LocalizedStrings.welcomeSubtitle)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .opacity(opacity * 0.8)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // 加载指示器
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    
                    Text(LocalizedStrings.welcomeLoading)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .opacity(opacity * 0.6)
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startWelcomeAnimation()
        }
        .fullScreenCover(isPresented: $showMainView) {
            MainTabView()
        }
    }
    
    private func startWelcomeAnimation() {
        // 启动动画
        withAnimation(.easeOut(duration: 0.8)) {
            isAnimating = true
            opacity = 1.0
            scale = 1.0
        }
        
        // 3秒后跳转到主页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showMainView = true
            }
        }
    }
}

#Preview {
    WelcomeView()
}
