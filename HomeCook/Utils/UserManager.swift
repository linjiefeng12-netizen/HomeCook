//
//  UserManager.swift
//  HomeCook
//
//  Created by CodeBuddy on 2025/1/8.
//

import Foundation
import SwiftUI

// 用户管理器 - 使用 Supabase 后端
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    
    private init() {
        // 监听 Supabase 服务的状态变化
        supabaseService.$isLoggedIn
            .assign(to: &$isLoggedIn)
        
        supabaseService.$currentUser
            .assign(to: &$currentUser)
    }
    
    // 用户注册
    @MainActor
    func register(fullName: String, email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await supabaseService.signUp(
                email: email,
                password: password,
                fullName: fullName
            )
            
            isLoading = false
            
            if success {
                errorMessage = nil
                return true
            } else {
                // 注册失败但没有具体错误
                errorMessage = NSLocalizedString("registration_failed", comment: "")
                return false
            }
        } catch let error as SupabaseError {
            isLoading = false
            switch error {
            case .emailAlreadyExists:
                errorMessage = NSLocalizedString("email_already_registered", comment: "")
            default:
                errorMessage = getErrorMessage(from: error)
            }
            return false
        } catch {
            isLoading = false
            errorMessage = getErrorMessage(from: error)
            return false
        }
    }
    
    // 用户登录
    @MainActor
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await supabaseService.signIn(
                email: email,
                password: password
            )
            
            isLoading = false
            
            if success {
                errorMessage = nil
                return true
            } else {
                errorMessage = "登录失败，请检查邮箱和密码"
                return false
            }
        } catch let error as SupabaseError {
            isLoading = false
            switch error {
            case .invalidCredentials:
                errorMessage = NSLocalizedString("login_error", comment: "")
            default:
                errorMessage = getErrorMessage(from: error)
            }
            return false
        } catch {
            isLoading = false
            errorMessage = getErrorMessage(from: error)
            return false
        }
    }
    
    // 用户登出
    @MainActor
    func logout() {
        isLoading = true
        
        Task {
            do {
                try await supabaseService.signOut()
                await MainActor.run {
                    isLoading = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = getErrorMessage(from: error)
                }
            }
        }
    }
    
    // 重置密码
    @MainActor
    func resetPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseService.resetPassword(email: email)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = getErrorMessage(from: error)
            return false
        }
    }
    
    // 更新用户信息
    @MainActor
    func updateUserProfile(fullName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseService.updateUser(fullName: fullName)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = getErrorMessage(from: error)
            return false
        }
    }
    
    // 清除错误信息
    func clearError() {
        errorMessage = nil
    }
    
    // 从错误中获取用户友好的错误信息
    private func getErrorMessage(from error: Error) -> String {
        if let supabaseError = error as? SupabaseError {
            return supabaseError.errorDescription ?? NSLocalizedString("unknown_error", comment: "")
        }
        
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("invalid login credentials") {
            return NSLocalizedString("login_error", comment: "")
        } else if errorDescription.contains("user already registered") {
            return NSLocalizedString("email_already_registered", comment: "")
        } else if errorDescription.contains("invalid email") {
            return "请输入有效的邮箱地址"
        } else if errorDescription.contains("password") {
            return "密码长度至少6位"
        } else if errorDescription.contains("network") {
            return "网络连接错误，请检查网络设置"
        } else {
            return error.localizedDescription
        }
    }
}

// 扩展 User 模型以支持显示格式
extension User {
    var displayName: String {
        return fullName.isEmpty ? email : fullName
    }
    
    var joinedYearsAgo: Int {
        // 由于这是新的实现，我们返回一个默认值
        // 在实际应用中，这个信息应该从 Supabase 获取
        return 1
    }
}