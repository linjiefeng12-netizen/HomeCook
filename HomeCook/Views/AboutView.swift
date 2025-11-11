//
//  AboutView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var id = UUID()
    @State private var showingTermsOfService = false
    @State private var showingPrivacyPolicy = false
    @State private var showingOpenSourceLicenses = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 美化的Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.about)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 应用信息卡片
                    EnhancedSettingsCard(
                        title: "HomeCook",
                        icon: "app.fill",
                        iconColor: .orange
                    ) {
                        VStack(spacing: 0) {
                            AboutInfoRow(
                                title: LocalizedStrings.currentVersion,
                                value: "1.0.0",
                                icon: "number.circle.fill"
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            AboutInfoRow(
                                title: LocalizedStrings.buildNumber,
                                value: "2025.01.01",
                                icon: "hammer.fill"
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            AboutInfoRow(
                                title: LocalizedStrings.developer,
                                value: "HomeCook Team",
                                icon: "person.2.fill"
                            )
                        }
                    }
                    
                    // 法律信息卡片
                    EnhancedSettingsCard(
                        title: LocalizedStrings.legalInfo,
                        icon: "doc.text.fill",
                        iconColor: .blue
                    ) {
                        VStack(spacing: 0) {
                            AboutActionRow(
                                title: LocalizedStrings.termsOfService,
                                icon: "doc.plaintext.fill",
                                action: {
                                    showingTermsOfService = true
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            AboutActionRow(
                                title: LocalizedStrings.privacyPolicy,
                                icon: "lock.shield.fill",
                                action: {
                                    showingPrivacyPolicy = true
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            AboutActionRow(
                                title: LocalizedStrings.openSourceLicenses,
                                icon: "doc.badge.gearshape.fill",
                                action: {
                                    showingOpenSourceLicenses = true
                                }
                            )
                        }
                    }
                    
                    // 版权信息
                    VStack(spacing: 8) {
                        Text("© 2025 HomeCook Team")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text(LocalizedStrings.allRightsReserved)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .padding(.top, 1)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .id(id)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
                self.id = UUID()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingOpenSourceLicenses) {
            LicenseView()
        }
    }
}

// 关于页面信息行组件
struct AboutInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // 标题
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // 值
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

// 关于页面操作行组件
struct AboutActionRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 服务条款页面
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 美化的Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "doc.plaintext.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.termsOfService)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 内容卡片
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStrings.termsOfServiceContent)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 隐私政策页面
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 美化的Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.privacyPolicy)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 内容卡片
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStrings.privacyPolicyContent)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 开源许可证页面
struct LicenseView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 美化的Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "doc.badge.gearshape.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.openSourceLicenses)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 内容卡片
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStrings.openSourceLicensesContent)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    AboutView()
        .environmentObject(LanguageManager())
}