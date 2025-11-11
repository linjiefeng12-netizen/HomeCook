//
//  PremiumView.swift
//  HomeCook
//
//  Created by CodeBuddy on 2025/1/8.
//

import SwiftUI

struct PremiumView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPlan: SubscriptionPlan = .halfYear
    @State private var showingPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // 头部区域
                    VStack(spacing: 20) {
                        // Premium 图标
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.yellow.opacity(0.8),
                                            Color.orange
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.orange.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            Text(LocalizedStrings.premiumTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text(LocalizedStrings.premiumSubtitle)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    
                    
                    // 订阅套餐
                    VStack(spacing: 16) {
                        Text(LocalizedStrings.choosePlan)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 12) {
                            // 免费试用
                            SubscriptionPlanCard(
                                plan: .freeTrial,
                                isSelected: selectedPlan == .freeTrial,
                                onTap: { selectedPlan = .freeTrial }
                            )
                            
                            // 半年订阅
                            SubscriptionPlanCard(
                                plan: .halfYear,
                                isSelected: selectedPlan == .halfYear,
                                onTap: { selectedPlan = .halfYear }
                            )
                            
                            // 全年订阅
                            SubscriptionPlanCard(
                                plan: .fullYear,
                                isSelected: selectedPlan == .fullYear,
                                onTap: { selectedPlan = .fullYear }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 订阅按钮
                    VStack(spacing: 16) {
                        Button(action: {
                            handleSubscription()
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 18))
                                
                                Text(selectedPlan == .freeTrial ? LocalizedStrings.startFreeTrial : LocalizedStrings.subscribe)
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
                            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        // 条款说明
                        Text(LocalizedStrings.subscriptionTerms)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizedStrings.premium)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(LocalizedStrings.close) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingPurchaseAlert) {
            Alert(
                title: Text(LocalizedStrings.subscriptionSuccess),
                message: Text(purchaseMessage),
                dismissButton: .default(Text(LocalizedStrings.ok)) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func handleSubscription() {
        switch selectedPlan {
        case .freeTrial:
            purchaseMessage = LocalizedStrings.freeTrialActivated
        case .halfYear:
            purchaseMessage = LocalizedStrings.halfYearSubscribed
        case .fullYear:
            purchaseMessage = LocalizedStrings.fullYearSubscribed
        }
        showingPurchaseAlert = true
    }
}

// 订阅套餐枚举
enum SubscriptionPlan: CaseIterable {
    case freeTrial
    case halfYear
    case fullYear
    
    var title: String {
        switch self {
        case .freeTrial:
            return LocalizedStrings.freeTrialTitle
        case .halfYear:
            return LocalizedStrings.halfYearTitle
        case .fullYear:
            return LocalizedStrings.fullYearTitle
        }
    }
    
    var price: String {
        switch self {
        case .freeTrial:
            return LocalizedStrings.free
        case .halfYear:
            return "$5.9"
        case .fullYear:
            return "$9.9"
        }
    }
    
    var period: String {
        switch self {
        case .freeTrial:
            return LocalizedStrings.oneMonth
        case .halfYear:
            return LocalizedStrings.sixMonths
        case .fullYear:
            return LocalizedStrings.oneYear
        }
    }
    
    var savings: String? {
        switch self {
        case .freeTrial:
            return nil
        case .halfYear:
            return nil
        case .fullYear:
            return LocalizedStrings.bestValue
        }
    }
}

// Premium 功能特色行
struct PremiumFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// 订阅套餐卡片
struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(plan.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(plan.price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(plan == .freeTrial ? .green : .orange)
                        
                        Text("/ \(plan.period)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .orange : .secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PremiumView()
}