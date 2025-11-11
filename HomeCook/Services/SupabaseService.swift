//
//  SupabaseService.swift
//  HomeCook
//
//  Created by CodeBuddy on 2025/1/1.
//

import Foundation

// 真实的 Supabase 服务实现
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    // Supabase 配置信息
    private let supabaseURL = "https://acntswpecnwgvrhpfhcq.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjbnRzd3BlY253Z3ZyaHBmaGNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwMzQwMTcsImV4cCI6MjA2OTYxMDAxN30.vBHBxhxr0Ln1im885jCto3UG7aWrtlQNT76wTPR6sG0"
    
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    
    // 会话存储键
    private let sessionKey = "HomeCookSupabaseSession"
    private let currentUserKey = "HomeCookSupabaseCurrentUser"
    
    private init() {
        // 检查当前登录状态
        loadCurrentSession()
    }
    
    // 从本地存储加载当前会话
    private func loadCurrentSession() {
        if let userData = UserDefaults.standard.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(User.self, from: userData),
           UserDefaults.standard.data(forKey: sessionKey) != nil {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    // 检查邮箱是否已存在 - 使用登录尝试的方法
    private func checkEmailExists(email: String) async throws -> Bool {
        // 使用一个明显错误的密码尝试登录来检查邮箱是否存在
        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "email": email,
            "password": "definitely_wrong_password_12345"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔍 检查邮箱是否存在: \(email)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        print("📝 邮箱检查响应状态码: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📝 邮箱检查响应内容: \(responseString)")
        }
        
        // 分析响应来判断邮箱是否存在
        if httpResponse.statusCode == 400 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📝 详细错误分析: \(json)")
                
                // 检查错误代码和消息
                if let errorCode = json["error_code"] as? String {
                    print("📝 错误代码: \(errorCode)")
                    
                    // 如果是凭据错误，说明邮箱存在但密码错误
                    if errorCode == "invalid_credentials" || errorCode.contains("credentials") {
                        print("✅ 邮箱存在（凭据错误）")
                        return true
                    }
                    
                    // 如果是邮箱未确认，说明邮箱存在但未验证
                    if errorCode == "email_not_confirmed" || errorCode.contains("not_confirmed") {
                        print("✅ 邮箱存在（未确认）")
                        return true
                    }
                    
                    // 如果是邮箱格式错误或不存在
                    if errorCode.contains("email") && (errorCode.contains("invalid") || errorCode.contains("not_found")) {
                        print("❌ 邮箱不存在或格式错误")
                        return false
                    }
                }
                
                // 检查错误消息
                if let msg = json["msg"] as? String {
                    print("📝 错误消息: \(msg)")
                    
                    let lowerMsg = msg.lowercased()
                    
                    // 如果提示凭据无效，说明邮箱存在
                    if lowerMsg.contains("invalid login credentials") || lowerMsg.contains("wrong password") {
                        print("✅ 邮箱存在（密码错误）")
                        return true
                    }
                    
                    // 如果提示邮箱未确认，说明邮箱存在
                    if lowerMsg.contains("email not confirmed") || lowerMsg.contains("not confirmed") {
                        print("✅ 邮箱存在（未确认）")
                        return true
                    }
                    
                    // 如果提示用户不存在
                    if lowerMsg.contains("user not found") || lowerMsg.contains("email not found") {
                        print("❌ 邮箱不存在")
                        return false
                    }
                }
            }
        }
        
        // 默认情况下，如果无法明确判断，假设邮箱不存在（允许注册）
        print("🤔 无法明确判断邮箱状态，默认允许注册")
        return false
    }
    
    // 用户注册
    func signUp(email: String, password: String, fullName: String) async throws -> Bool {
        print("🔍 开始用户注册流程...")
        
        let url = URL(string: "\(supabaseURL)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
            "options": [
                "data": [
                    "full_name": fullName
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔗 Supabase 注册请求:")
        print("URL: \(url)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ 无效的 HTTP 响应")
            throw SupabaseError.networkError
        }
        
        print("📡 Supabase 注册响应:")
        print("状态码: \(httpResponse.statusCode)")
        print("响应头: \(httpResponse.allHeaderFields)")
        print("响应数据: \(String(data: data, encoding: .utf8) ?? "")")
        
        // 详细分析响应内容
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔍 详细响应分析:")
            print("- 响应长度: \(responseString.count) 字符")
            print("- 是否包含 'user': \(responseString.contains("user"))")
            print("- 是否包含 'error': \(responseString.contains("error"))")
            print("- 是否包含 'already': \(responseString.contains("already"))")
            print("- 是否包含 'registered': \(responseString.contains("registered"))")
            print("- 是否包含 'exists': \(responseString.contains("exists"))")
        }
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("✅ 注册成功响应: \(json)")
                
                // 检查响应中是否直接包含用户信息（Supabase 直接返回用户对象）
                if let userId = json["id"] as? String,
                   let userEmail = json["email"] as? String {
                    
                    print("✅ 注册成功，用户ID: \(userId), 邮箱: \(userEmail)")
                    
                    let newUser = User(
                        id: userId,
                        fullName: fullName,
                        email: userEmail
                    )
                    
                    await MainActor.run {
                        self.currentUser = newUser
                        self.isLoggedIn = true
                        
                        // 保存用户信息和会话
                        if let userData = try? JSONEncoder().encode(newUser) {
                            UserDefaults.standard.set(userData, forKey: self.currentUserKey)
                        }
                        UserDefaults.standard.set(data, forKey: self.sessionKey)
                    }
                    
                    return true
                }
                
                // 检查是否有嵌套的 user 对象
                if let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String,
                   let userEmail = user["email"] as? String {
                    
                    print("✅ 注册成功，嵌套用户信息 - ID: \(userId), 邮箱: \(userEmail)")
                    
                    let newUser = User(
                        id: userId,
                        fullName: fullName,
                        email: userEmail
                    )
                    
                    await MainActor.run {
                        self.currentUser = newUser
                        self.isLoggedIn = true
                        
                        // 保存用户信息和会话
                        if let userData = try? JSONEncoder().encode(newUser) {
                            UserDefaults.standard.set(userData, forKey: self.currentUserKey)
                        }
                        UserDefaults.standard.set(data, forKey: self.sessionKey)
                    }
                    
                    return true
                }
                
                print("⚠️ 注册响应中缺少必要的用户信息")
                throw SupabaseError.networkError
            } else {
                print("⚠️ 无法解析注册响应，但状态码表示成功")
                // 尝试登录来验证用户是否已存在
                do {
                    let loginSuccess = try await self.signIn(email: email, password: password)
                    if loginSuccess {
                        print("✅ 通过登录验证，注册成功")
                        return true
                    }
                } catch {
                    print("⚠️ 登录验证失败: \(error)")
                }
                
                // 如果登录失败，可能是邮箱已存在但密码不匹配
                throw SupabaseError.emailAlreadyExists
            }
        } else {
            // 处理错误响应
            print("🚨 注册失败，开始详细分析错误响应...")
            
            // 尝试解析 JSON 响应
            var jsonResponse: [String: Any]? = nil
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                jsonResponse = json
                print("✅ JSON 解析成功: \(json)")
            } else {
                print("❌ JSON 解析失败，原始响应: \(String(data: data, encoding: .utf8) ?? "无法解码")")
            }
            
            // 分析所有可能的错误字段
            if let json = jsonResponse {
                print("🔍 错误字段分析:")
                
                // 检查所有可能的错误字段
                let errorFields = ["error", "error_description", "msg", "message", "error_code", "code"]
                for field in errorFields {
                    if let value = json[field] {
                        print("- \(field): \(value)")
                    }
                }
                
                // 检查是否有 OAuth 2.0 相关的错误
                if let error = json["error"] as? String {
                    print("📝 OAuth 错误类型: \(error)")
                    
                    // OAuth 2.0 标准错误码分析
                    switch error.lowercased() {
                    case "invalid_request":
                        print("🔍 OAuth 错误: 无效请求")
                        throw SupabaseError.invalidEmail
                    case "invalid_client":
                        print("🔍 OAuth 错误: 无效客户端")
                        throw SupabaseError.networkError
                    case "invalid_grant":
                        print("🔍 OAuth 错误: 无效授权")
                        throw SupabaseError.networkError
                    case "unauthorized_client":
                        print("🔍 OAuth 错误: 未授权客户端")
                        throw SupabaseError.networkError
                    case "unsupported_grant_type":
                        print("🔍 OAuth 错误: 不支持的授权类型")
                        throw SupabaseError.networkError
                    default:
                        print("🔍 未知 OAuth 错误: \(error)")
                    }
                }
                
                // 检查错误描述
                if let errorDescription = json["error_description"] as? String {
                    print("📝 错误描述: \(errorDescription)")
                    
                    let lowerDescription = errorDescription.lowercased()
                    if lowerDescription.contains("user already registered") ||
                       lowerDescription.contains("email already exists") ||
                       lowerDescription.contains("already registered") {
                        print("🔍 确认: 用户已存在")
                        throw SupabaseError.emailAlreadyExists
                    } else if lowerDescription.contains("invalid email") ||
                              lowerDescription.contains("email format") ||
                              lowerDescription.contains("malformed email") {
                        print("🔍 确认: 邮箱格式无效")
                        throw SupabaseError.invalidEmail
                    } else if lowerDescription.contains("password") &&
                              (lowerDescription.contains("weak") ||
                               lowerDescription.contains("short") ||
                               lowerDescription.contains("minimum")) {
                        print("🔍 确认: 密码强度不足")
                        throw SupabaseError.weakPassword
                    }
                }
                
                // 检查 Supabase 特定的错误信息
                if let msg = json["msg"] as? String {
                    print("📝 Supabase 消息: \(msg)")
                    
                    let lowerMsg = msg.lowercased()
                    if lowerMsg.contains("user already registered") ||
                       lowerMsg.contains("email already exists") {
                        print("🔍 确认: 用户已存在 (来自 msg 字段)")
                        throw SupabaseError.emailAlreadyExists
                    }
                }
                
                // 检查错误代码
                if let errorCode = json["error_code"] as? String {
                    print("📝 错误代码: \(errorCode)")
                    
                    switch errorCode.lowercased() {
                    case "email_address_invalid", "invalid_email":
                        print("🔍 确认: 邮箱无效 (来自错误代码)")
                        throw SupabaseError.invalidEmail
                    case "user_already_registered", "email_already_exists":
                        print("🔍 确认: 用户已存在 (来自错误代码)")
                        throw SupabaseError.emailAlreadyExists
                    case "weak_password", "password_too_short":
                        print("🔍 确认: 密码强度不足 (来自错误代码)")
                        throw SupabaseError.weakPassword
                    default:
                        print("🔍 未知错误代码: \(errorCode)")
                    }
                }
            }
            
            // 根据 HTTP 状态码进行最终判断
            print("🔍 HTTP 状态码分析: \(httpResponse.statusCode)")
            switch httpResponse.statusCode {
            case 400:
                // 400 错误通常是请求格式问题，但需要检查具体错误信息
                if let json = jsonResponse,
                   let errorCode = json["error_code"] as? String,
                   errorCode.contains("already") || errorCode.contains("exists") {
                    print("🔍 400 错误: 用户已存在")
                    throw SupabaseError.emailAlreadyExists
                } else {
                    print("🔍 400 错误: 请求格式错误，可能是邮箱格式问题")
                    throw SupabaseError.invalidEmail
                }
            case 409:
                print("🔍 409 错误: 资源冲突，用户已存在")
                throw SupabaseError.emailAlreadyExists
            case 422:
                // 422 通常是验证失败，但需要具体分析
                if let json = jsonResponse,
                   let msg = json["msg"] as? String,
                   msg.lowercased().contains("already") {
                    print("🔍 422 错误: 用户已存在")
                    throw SupabaseError.emailAlreadyExists
                } else {
                    print("🔍 422 错误: 验证失败，可能是密码强度不足")
                    throw SupabaseError.weakPassword
                }
            case 401:
                print("🔍 401 错误: 未授权，可能是 API 密钥问题")
                throw SupabaseError.networkError
            case 403:
                print("🔍 403 错误: 禁止访问")
                throw SupabaseError.networkError
            case 429:
                print("🔍 429 错误: 请求过于频繁")
                throw SupabaseError.networkError
            case 500...599:
                print("🔍 5xx 错误: 服务器内部错误")
                throw SupabaseError.networkError
            default:
                print("🔍 未知状态码: \(httpResponse.statusCode)")
                // 对于未知状态码，默认当作网络错误处理，不要误判为用户已存在
                throw SupabaseError.networkError
            }
        }
    }
    
    // 用户登录
    func signIn(email: String, password: String) async throws -> Bool {
        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔗 Supabase 登录请求:")
        print("URL: \(url)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ 无效的 HTTP 响应")
            throw SupabaseError.networkError
        }
        
        print("📡 Supabase 登录响应:")
        print("状态码: \(httpResponse.statusCode)")
        print("响应数据: \(String(data: data, encoding: .utf8) ?? "")")
        
        if httpResponse.statusCode == 200 {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("✅ 登录成功响应: \(json)")
                
                if let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String,
                   let userEmail = user["email"] as? String {
                    
                    // 获取用户元数据中的全名
                    let userMetadata = user["user_metadata"] as? [String: Any]
                    let fullName = userMetadata?["full_name"] as? String ?? "用户"
                    
                    let loggedInUser = User(
                        id: userId,
                        fullName: fullName,
                        email: userEmail
                    )
                    
                    await MainActor.run {
                        self.currentUser = loggedInUser
                        self.isLoggedIn = true
                        
                        // 保存用户信息和会话
                        if let userData = try? JSONEncoder().encode(loggedInUser) {
                            UserDefaults.standard.set(userData, forKey: self.currentUserKey)
                        }
                        UserDefaults.standard.set(data, forKey: self.sessionKey)
                    }
                    
                    return true
                } else {
                    print("⚠️ 登录响应中缺少用户信息")
                }
            }
        } else {
            // 处理错误响应
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("❌ 登录错误响应: \(json)")
                
                // 检查错误消息
                if let errorMessage = json["msg"] as? String {
                    print("📝 Supabase 登录错误: \(errorMessage)")
                    
                    let lowerMessage = errorMessage.lowercased()
                    
                    // 根据具体错误信息判断错误类型
                    if lowerMessage.contains("invalid login credentials") || 
                       lowerMessage.contains("wrong password") ||
                       lowerMessage.contains("user not found") ||
                       lowerMessage.contains("email not found") {
                        throw SupabaseError.invalidCredentials
                    } else if lowerMessage.contains("email not confirmed") ||
                              lowerMessage.contains("not confirmed") {
                        throw SupabaseError.emailNotConfirmed
                    } else {
                        throw SupabaseError.invalidCredentials
                    }
                }
                
                // 检查错误代码
                if let errorCode = json["error_code"] as? String {
                    print("📝 Supabase 错误代码: \(errorCode)")
                    
                    switch errorCode.lowercased() {
                    case "invalid_credentials", "invalid_login_credentials":
                        throw SupabaseError.invalidCredentials
                    case "email_not_confirmed":
                        throw SupabaseError.emailNotConfirmed
                    case "user_not_found":
                        throw SupabaseError.userNotFound
                    default:
                        throw SupabaseError.invalidCredentials
                    }
                }
                
                // 检查其他可能的错误字段
                if let error = json["error"] as? String {
                    print("📝 Supabase 登录错误: \(error)")
                    throw SupabaseError.invalidCredentials
                }
                
                // 检查 error_description 字段
                if let errorDescription = json["error_description"] as? String {
                    print("📝 Supabase 错误描述: \(errorDescription)")
                    throw SupabaseError.invalidCredentials
                }
            }
            
            // 根据状态码判断错误类型
            switch httpResponse.statusCode {
            case 400:
                throw SupabaseError.invalidCredentials
            case 401:
                throw SupabaseError.invalidCredentials
            case 404:
                throw SupabaseError.userNotFound
            default:
                throw SupabaseError.networkError
            }
        }
        
        return false
    }
    
    // 用户登出
    func signOut() async throws {
        let url = URL(string: "\(supabaseURL)/auth/v1/logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        // 获取当前会话令牌
        if let sessionData = UserDefaults.standard.data(forKey: sessionKey),
           let json = try JSONSerialization.jsonObject(with: sessionData) as? [String: Any],
           let accessToken = json["access_token"] as? String {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard response is HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        // 无论服务器响应如何，都清除本地会话
        await MainActor.run {
            self.currentUser = nil
            self.isLoggedIn = false
            
            // 清除本地存储
            UserDefaults.standard.removeObject(forKey: self.sessionKey)
            UserDefaults.standard.removeObject(forKey: self.currentUserKey)
        }
    }
    
    // 重置密码
    func resetPassword(email: String) async throws {
        let url = URL(string: "\(supabaseURL)/auth/v1/recover")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        let requestBody: [String: Any] = [
            "email": email
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            throw SupabaseError.userNotFound
        }
    }
    
    // 更新用户信息
    func updateUser(fullName: String) async throws {
        guard let currentUser = currentUser else {
            throw SupabaseError.userNotFound
        }
        
        let url = URL(string: "\(supabaseURL)/auth/v1/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        // 获取当前会话令牌
        if let sessionData = UserDefaults.standard.data(forKey: sessionKey),
           let json = try JSONSerialization.jsonObject(with: sessionData) as? [String: Any],
           let accessToken = json["access_token"] as? String {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let requestBody: [String: Any] = [
            "data": [
                "full_name": fullName
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        if httpResponse.statusCode == 200 {
            let updatedUser = User(
                id: currentUser.id,
                fullName: fullName,
                email: currentUser.email
            )
            
            await MainActor.run {
                self.currentUser = updatedUser
                
                // 更新本地存储
                if let userData = try? JSONEncoder().encode(updatedUser) {
                    UserDefaults.standard.set(userData, forKey: self.currentUserKey)
                }
            }
        } else {
            throw SupabaseError.networkError
        }
    }
}

// 用户模型
struct User: Codable {
    let id: String
    let fullName: String
    let email: String
}

// 错误类型
enum SupabaseError: LocalizedError {
    case emailAlreadyExists
    case invalidCredentials
    case userNotFound
    case emailNotConfirmed
    case networkError
    case invalidEmail
    case weakPassword
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyExists:
            return NSLocalizedString("email_already_registered", comment: "")
        case .invalidCredentials:
            return NSLocalizedString("invalid_credentials", comment: "")
        case .userNotFound:
            return NSLocalizedString("user_not_found", comment: "")
        case .emailNotConfirmed:
            return NSLocalizedString("email_not_confirmed", comment: "")
        case .networkError:
            return NSLocalizedString("network_error", comment: "")
        case .invalidEmail:
            return NSLocalizedString("invalid_email_format", comment: "")
        case .weakPassword:
            return NSLocalizedString("weak_password", comment: "")
        }
    }
}
