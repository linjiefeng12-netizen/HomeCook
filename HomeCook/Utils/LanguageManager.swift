//
//  LanguageManager.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

enum AppLanguage: String {
    case chinese = "zh-Hans"
    case english = "en"
    case german = "de"
    case spanish = "es"
    case japanese = "ja"
    case korean = "ko"
    case russian = "ru"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .chinese:
            return "简体中文"
        case .english:
            return "English"
        case .german:
            return "Deutsch"
        case .spanish:
            return "Español"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .russian:
            return "Русский"
        case .french:
            return "Français"
        }
    }
}

class LanguageManager: ObservableObject {
    @AppStorage("appLanguage") var currentLanguage: String = "en" {
        didSet {
            applyLanguage()
        }
    }
    
    @Published var locale: Locale = Locale(identifier: "zh-Hans")
    
    init() {
        applyLanguage()
    }
    
    func applyLanguage() {
        locale = Locale(identifier: currentLanguage)
        
        // 更新系统首选语言
        UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 打印当前使用的语言
        print("当前应用语言设置为: \(currentLanguage)")
        
        // 确保本地化文件在正确的位置
        moveLocalizationFilesToResources()
        
        // 重新加载本地化字符串
        reloadLocalizedStrings()
        
        // 应用语言变更
        applyLanguageChange()
    }
    
    // 重新加载本地化字符串
    private func reloadLocalizedStrings() {
        // 清除LocalizationManager的缓存
        LocalizationManager.shared.reloadLocalizedStrings()
        
        // 强制刷新所有使用本地化字符串的视图
        NotificationCenter.default.post(name: NSNotification.Name("ReloadLocalizedStrings"), object: nil)
    }
    
    // 应用语言变更
    private func applyLanguageChange() {
        // 在主线程上执行，确保UI操作安全
        DispatchQueue.main.async {
            // 打印语言变更信息
            print("应用语言已更改为: \(self.currentLanguage)")
            
            // 强制刷新所有使用本地化字符串的视图
            NotificationCenter.default.post(name: NSNotification.Name("ForceRefreshViews"), object: nil)
            
            // 通知系统语言已更改
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            
            // 强制刷新所有视图
            NotificationCenter.default.post(name: NSNotification.Name("ForceRefreshAllViews"), object: nil)
        }
    }
    
    func getLanguageDisplayName() -> String {
        if let language = AppLanguage(rawValue: currentLanguage) {
            return language.displayName
        }
        return "简体中文"
    }
    
    // 将本地化文件移动到Resources目录
    private func moveLocalizationFilesToResources() {
        let fileManager = FileManager.default
        let languages = ["zh-Hans", "en", "de", "es", "ja", "ko", "ru", "fr"]
        
        // 获取应用的文档目录
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path else {
            return
        }
        
        // 创建Resources目录
        let resourcesPath = documentsDirectory + "/Resources"
        if !fileManager.fileExists(atPath: resourcesPath) {
            try? fileManager.createDirectory(atPath: resourcesPath, withIntermediateDirectories: true)
        }
        
        for language in languages {
            // 创建语言目录
            let langPath = resourcesPath + "/\(language).lproj"
            if !fileManager.fileExists(atPath: langPath) {
                try? fileManager.createDirectory(atPath: langPath, withIntermediateDirectories: true)
            }
            
            // 检查根目录中的本地化文件
            let rootLangPath = Bundle.main.bundlePath + "/\(language).lproj"
            let rootLocalizablePath = rootLangPath + "/Localizable.strings"
            let resourcesLocalizablePath = langPath + "/Localizable.strings"
            
            // 如果根目录中有本地化文件，复制到Resources目录
            if fileManager.fileExists(atPath: rootLocalizablePath) && !fileManager.fileExists(atPath: resourcesLocalizablePath) {
                try? fileManager.copyItem(atPath: rootLocalizablePath, toPath: resourcesLocalizablePath)
                print("已将 \(language) 本地化文件从根目录复制到 Resources 目录")
            }
        }
    }
}
