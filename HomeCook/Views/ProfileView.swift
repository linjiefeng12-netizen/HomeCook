//
//  ProfileView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @State private var showingHistory = false
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var showingFavorites = false
    @State private var showingPremium = false
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: UIImage?
    @StateObject private var userManager = UserManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var id = UUID() // 添加ID用于强制刷新视图
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if userManager.isLoggedIn {
                        // 已登录用户的头部区域
                        VStack(spacing: 20) {
                            // 头像
                            Button(action: {
                                showingActionSheet = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    if let profileImage = profileImage {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // 编辑图标
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 28, height: 28)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                                
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.orange)
                                            }
                                            .offset(x: -8, y: -8)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 用户信息
                            VStack(spacing: 8) {
                                Text(userManager.currentUser?.fullName ?? "用户")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(LocalizedStrings.premiumMember)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.orange.opacity(0.15))
                                    )
                                
                                Text("joined_years_ago".localized(with: 1))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    } else {
                        // 未登录用户的登录/注册区域
                        LoginRegisterView()
                            .padding(.top, 20)
                    }
                    
                    // 菜单项卡片 - 只有登录用户才显示
                    if userManager.isLoggedIn {
                        VStack(alignment: .leading, spacing: 0) {
                            // 菜单卡片
                            VStack(spacing: 0) {
                                EnhancedProfileMenuItem(
                                    icon: "crown.fill",
                                    iconColor: .yellow,
                                    title: LocalizedStrings.premium,
                                    action: {
                                        showingPremium = true
                                    }
                                )
                                
                                EnhancedProfileMenuItem(
                                    icon: "clock.fill",
                                    iconColor: .orange,
                                    title: LocalizedStrings.history,
                                    action: {
                                        showingHistory = true
                                    }
                                )
                                
                                EnhancedProfileMenuItem(
                                    icon: "heart.fill",
                                    iconColor: .red,
                                    title: LocalizedStrings.myFavorites,
                                    action: {
                                        showingFavorites = true
                                    }
                                )
                                
                                EnhancedProfileMenuItem(
                                    icon: "gearshape.fill",
                                    iconColor: .gray,
                                    title: LocalizedStrings.settings,
                                    action: {
                                        showingSettings = true
                                    }
                                )
                                
                                EnhancedProfileMenuItem(
                                    icon: "info.circle.fill",
                                    iconColor: .purple,
                                    title: LocalizedStrings.about,
                                    action: {
                                        showingAbout = true
                                    }
                                )
                                
                                EnhancedProfileMenuItem(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    iconColor: .red,
                                    title: LocalizedStrings.logout,
                                    action: {
                                        userManager.logout()
                                    },
                                    showDivider: false
                                )
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 16)
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
            .padding(.top, 1) // 添加最小顶部间距，防止内容覆盖状态栏
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .id(id) // 使用id强制刷新整个视图
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
                // 收到刷新通知时更新ID，强制刷新视图
                self.id = UUID()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView()
        }
        .sheet(isPresented: $showingPremium) {
            PremiumView()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("更换头像"),
                message: Text("选择头像来源"),
                buttons: [
                    .default(Text("从相册选择")) {
                        showingImagePicker = true
                    },
                    .default(Text("使用默认头像")) {
                        profileImage = nil
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let newImage = newValue {
                profileImage = newImage
                // 保存头像到本地
                saveProfileImage(newImage)
            }
        }
        .onAppear {
            // 加载保存的头像
            loadProfileImage()
        }
    }
    
    // 保存头像到本地
    private func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imagePath = documentsPath.appendingPathComponent("profile_image.jpg")
            
            do {
                try data.write(to: imagePath)
                print("头像保存成功")
            } catch {
                print("头像保存失败: \(error)")
            }
        }
    }
    
    // 从本地加载头像
    private func loadProfileImage() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = documentsPath.appendingPathComponent("profile_image.jpg")
        
        if let data = try? Data(contentsOf: imagePath),
           let image = UIImage(data: data) {
            profileImage = image
            print("头像加载成功")
        }
    }
}

// 美化的菜单项组件
struct EnhancedProfileMenuItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    var showDivider: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 16) {
                    // 图标
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(iconColor)
                    }
                    
                    // 标题
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 箭头
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if showDivider {
                Divider()
                    .padding(.leading, 68)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
}
