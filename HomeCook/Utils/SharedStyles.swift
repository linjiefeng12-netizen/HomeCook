//
//  SharedStyles.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

// 按钮缩放效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}