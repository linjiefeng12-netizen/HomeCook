//
//  SettingsView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    // 添加ID用于强制刷新视图
    @State private var id = UUID()
    
    // 支持的语言列表
    let languages = [
        ("en", "English"),
        ("de", "Deutsch"),
        ("es", "Español"),
        ("ja", "日本語"),
        ("ko", "한국어"),
        ("ru", "Русский"),
        ("fr", "Français"),
        ("zh-Hans", "简体中文")
    ]
    
    // 主题选项
    var themes: [(String, String)] {
        [
            ("dark", LocalizedStrings.darkMode),
            ("light", LocalizedStrings.lightMode)
        ]
    }
    
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
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.settingsTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 语言设置卡片
                    EnhancedSettingsCard(
                        title: LocalizedStrings.languageSettings,
                        icon: "globe",
                        iconColor: .blue
                    ) {
                        VStack(spacing: 0) {
                            ForEach(languages, id: \.0) { lang in
                                LanguageSettingsRow(
                                    title: lang.1,
                                    flagEmoji: getFlagEmojiForLanguage(for: lang.0),
                                    isSelected: languageManager.currentLanguage == lang.0,
                                    action: {
                                        if languageManager.currentLanguage != lang.0 {
                                            // 添加触觉反馈
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                languageManager.currentLanguage = lang.0
                                                self.id = UUID()
                                                NotificationCenter.default.post(name: NSNotification.Name("ForceRefreshAllViews"), object: nil)
                                            }
                                        }
                                    }
                                )
                                
                                if lang.0 != languages.last?.0 {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                    }
                    
                    // 主题设置卡片
                    EnhancedSettingsCard(
                        title: LocalizedStrings.themeSettings,
                        icon: "paintbrush.fill",
                        iconColor: .purple
                    ) {
                        VStack(spacing: 0) {
                            ForEach(themes, id: \.0) { theme in
                                EnhancedSettingsRow(
                                    title: theme.1,
                                    icon: getThemeIcon(for: theme.0),
                                    isSelected: themeManager.currentTheme == theme.0,
                                    action: {
                                        if themeManager.currentTheme != theme.0 {
                                            // 添加触觉反馈
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                themeManager.currentTheme = theme.0
                                                self.id = UUID()
                                            }
                                        }
                                    }
                                )
                                
                                if theme.0 != themes.last?.0 {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                    }
                    
                    // 版本信息
                    VStack(spacing: 8) {
                        Text("HomeCook")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("V1.0.0")
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
            .padding(.top, 1) // 添加最小顶部间距，防止内容覆盖状态栏
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))) { _ in
                // 收到主题变化通知时更新ID，强制刷新视图
                self.id = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
                // 收到刷新通知时更新ID，强制刷新视图
                self.id = UUID()
            }
            .onAppear {
                // 打印当前使用的主题
                print("当前主题: \(themeManager.currentTheme)")
                print("深色模式文本: \(LocalizedStrings.darkMode)")
                print("浅色模式文本: \(LocalizedStrings.lightMode)")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // 获取语言图标
    private func getLanguageIcon(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗图标
    private func getFlagIcon(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗图标 - 使用不同的系统图标
    private func getCountryFlagIcon(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗图标 - 使用不同的系统图标
    private func getFlagIconForCountry(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗图标 - 使用不同的系统图标
    private func getFlagIconForLanguage(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗图标 - 使用不同的系统图标
    private func getFlagIconForLanguage2(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗图标 - 使用不同的系统图标
    private func getFlagIconForLanguage3(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "flag.filled.and.flag.crossed" // 英国国旗
        case "de":
            return "flag.filled.and.flag.crossed" // 德国国旗
        case "es":
            return "flag.filled.and.flag.crossed" // 西班牙国旗
        case "ja":
            return "flag.filled.and.flag.crossed" // 日本国旗
        case "ko":
            return "flag.filled.and.flag.crossed" // 韩国国旗
        case "ru":
            return "flag.filled.and.flag.crossed" // 俄罗斯国旗
        case "fr":
            return "flag.filled.and.flag.crossed" // 法国国旗
        case "zh-Hans":
            return "flag.filled.and.flag.crossed" // 中国国旗
        default:
            return "globe"
        }
    }
    
    // 获取国旗emoji
    private func getFlagEmojiForLanguage(for languageCode: String) -> String {
        switch languageCode {
        case "en":
            return "🇺🇸"// 美国国旗
        case "de":
            return "🇩🇪" // 德国国旗
        case "es":
            return "🇪🇸" // 西班牙国旗
        case "ja":
            return "🇯🇵" // 日本国旗
        case "ko":
            return "🇰🇷" // 韩国国旗
        case "ru":
            return "🇷🇺" // 俄罗斯国旗
        case "fr":
            return "🇫🇷" // 法国国旗
        case "zh-Hans":
            return "🇨🇳" // 中国国旗
        default:
            return "🌍"
        }
    }
    
    // 获取主题图标
    private func getThemeIcon(for theme: String) -> String {
        switch theme {
        case "dark":
            return "moon.fill"
        case "light":
            return "sun.max.fill"
        default:
            return "paintbrush.fill"
        }
    }
}

// 美化的设置卡片组件
struct EnhancedSettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconColor)
                    )
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

// 美化的设置行组件
struct EnhancedSettingsRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .orange : .secondary)
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 选中指示器
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 24, height: 24)
                            .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.05) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 专门用于语言选择的设置行组件，使用emoji国旗
struct LanguageSettingsRow: View {
    let title: String
    let flagEmoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 国旗emoji
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Text(flagEmoji)
                        .font(.system(size: 20))
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 选中指示器
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 24, height: 24)
                            .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.05) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
}
