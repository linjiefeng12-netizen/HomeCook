//
//  LoginRegisterView.swift
//  HomeCook
//
//  Created by CodeBuddy on 2025/1/8.
//

import SwiftUI

struct LoginRegisterView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @ObservedObject private var userManager = UserManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // 头像占位符
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
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // 标题
            VStack(spacing: 8) {
            Text(isLoginMode ? LocalizedStrings.login : LocalizedStrings.register)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(isLoginMode ? LocalizedStrings.welcomeBack : LocalizedStrings.createNewAccount)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            
            // 表单
            VStack(spacing: 16) {
                // 注册时显示姓名输入框
                if !isLoginMode {
                    CustomTextField(
                        placeholder: LocalizedStrings.fullName,
                        text: $name,
                        icon: "person"
                    )
                }
                
                // 邮箱输入框
                CustomTextField(
                    placeholder: LocalizedStrings.email,
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )
                
                // 密码输入框
                CustomSecureField(
                    placeholder: LocalizedStrings.password,
                    text: $password,
                    icon: "lock"
                )
                
                // 注册时显示确认密码输入框
                if !isLoginMode {
                    CustomSecureField(
                        placeholder: LocalizedStrings.confirmPassword,
                        text: $confirmPassword,
                        icon: "lock"
                    )
                }
            }
            
            // 登录/注册按钮
            Button(action: {
                if isLoginMode {
                    performLogin()
                } else {
                    performRegister()
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: isLoginMode ? "arrow.right.circle.fill" : "person.badge.plus.fill")
                            .font(.system(size: 20))
                    }
                    
                    Text(isLoading ? LocalizedStrings.processing : (isLoginMode ? LocalizedStrings.login : LocalizedStrings.register))
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty || (!isLoginMode && (name.isEmpty || confirmPassword.isEmpty)))
            
            // 切换登录/注册模式
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoginMode.toggle()
                    clearFields()
                }
            }) {
                HStack(spacing: 4) {
                    Text(isLoginMode ? LocalizedStrings.dontHaveAccount : LocalizedStrings.alreadyHaveAccount)
                        .foregroundColor(.secondary)
                    
                    Text(isLoginMode ? LocalizedStrings.register : LocalizedStrings.login)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 16))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(LocalizedStrings.notice),
                message: Text(alertMessage),
                dismissButton: .default(Text(LocalizedStrings.ok))
            )
        }
    }
    
    // 执行登录
    private func performLogin() {
        isLoading = true
        
        Task {
            let success = await userManager.login(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                if !success {
                    // 使用 UserManager 中的错误信息
                    alertMessage = userManager.errorMessage ?? NSLocalizedString("login_failed_message", comment: "")
                    showingAlert = true
                }
            }
        }
    }
    
    // 执行注册
    private func performRegister() {
        // 验证输入
        if password != confirmPassword {
            alertMessage = NSLocalizedString("passwords_dont_match", comment: "")
            showingAlert = true
            return
        }
        
        if password.count < 6 {
            alertMessage = NSLocalizedString("password_min_length", comment: "")
            showingAlert = true
            return
        }
        
        if !isValidEmail(email) {
            alertMessage = NSLocalizedString("invalid_email_format", comment: "")
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            let success = await userManager.register(fullName: name, email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                if !success {
                    // 使用 UserManager 中的错误信息
                    alertMessage = userManager.errorMessage ?? NSLocalizedString("registration_failed_message", comment: "")
                    showingAlert = true
                }
            }
        }
    }
    
    // 清空输入框
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
    }
    
    // 验证邮箱格式
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// 自定义文本输入框
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.orange)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// 自定义密码输入框
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.orange)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    LoginRegisterView()
}