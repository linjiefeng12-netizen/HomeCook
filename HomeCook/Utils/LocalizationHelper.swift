//
//  LocalizationHelper.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import Foundation

// 创建一个单例来管理本地化资源包
class LocalizationManager {
    static let shared = LocalizationManager()
    
    // 缓存本地化字符串
    private var cachedStrings: [String: [String: String]] = [:]
    
    // 获取当前语言的本地化文件
    func localizedString(for key: String, comment: String = "") -> String {
        // 获取当前语言
        let currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        // 检查缓存
        if let cachedValue = cachedStrings[currentLanguage]?[key] {
            return cachedValue
        }
        
        // 打印调试信息
        print("正在查找本地化字符串: \(key) (语言: \(currentLanguage))")
        
        // 首先尝试从Resources目录加载
        if let resourcesPath = Bundle.main.path(forResource: "Resources/\(currentLanguage).lproj/Localizable", ofType: "strings") {
            if let resourcesDict = NSDictionary(contentsOfFile: resourcesPath) as? [String: String] {
                // 缓存整个字典
                if cachedStrings[currentLanguage] == nil {
                    cachedStrings[currentLanguage] = resourcesDict
                } else {
                    for (dictKey, dictValue) in resourcesDict {
                        cachedStrings[currentLanguage]?[dictKey] = dictValue
                    }
                }
                
                if let localizedString = resourcesDict[key] {
                    print("在Resources目录找到本地化字符串: \(key) = \(localizedString)")
                    return localizedString
                }
            }
        }
        
        // 如果Resources目录中没有找到，尝试从主Bundle加载
        if let mainPath = Bundle.main.path(forResource: "\(currentLanguage).lproj/Localizable", ofType: "strings") {
            if let mainDict = NSDictionary(contentsOfFile: mainPath) as? [String: String] {
                // 缓存整个字典
                if cachedStrings[currentLanguage] == nil {
                    cachedStrings[currentLanguage] = mainDict
                } else {
                    for (dictKey, dictValue) in mainDict {
                        cachedStrings[currentLanguage]?[dictKey] = dictValue
                    }
                }
                
                if let localizedString = mainDict[key] {
                    print("在主Bundle找到本地化字符串: \(key) = \(localizedString)")
                    return localizedString
                }
            }
        }
        
        // 如果当前语言没有找到，尝试英语作为备选
        if currentLanguage != "en" {
            print("尝试使用英语作为备选")
            
            // 检查英语缓存
            if let cachedEnValue = cachedStrings["en"]?[key] {
                return cachedEnValue
            }
            
            if let enPath = Bundle.main.path(forResource: "Resources/en.lproj/Localizable", ofType: "strings") {
                if let enDict = NSDictionary(contentsOfFile: enPath) as? [String: String] {
                    // 缓存整个字典
                    if cachedStrings["en"] == nil {
                        cachedStrings["en"] = enDict
                    } else {
                        for (dictKey, dictValue) in enDict {
                            cachedStrings["en"]?[dictKey] = dictValue
                        }
                    }
                    
                    if let localizedString = enDict[key] {
                        print("在英语本地化文件中找到: \(key) = \(localizedString)")
                        return localizedString
                    }
                }
            }
            
            if let enMainPath = Bundle.main.path(forResource: "en.lproj/Localizable", ofType: "strings") {
                if let enMainDict = NSDictionary(contentsOfFile: enMainPath) as? [String: String] {
                    // 缓存整个字典
                    if cachedStrings["en"] == nil {
                        cachedStrings["en"] = enMainDict
                    } else {
                        for (dictKey, dictValue) in enMainDict {
                            cachedStrings["en"]?[dictKey] = dictValue
                        }
                    }
                    
                    if let localizedString = enMainDict[key] {
                        print("在主Bundle的英语本地化文件中找到: \(key) = \(localizedString)")
                        return localizedString
                    }
                }
            }
        }
        
        // 如果所有尝试都失败，返回键本身
        print("未找到本地化字符串: \(key)，返回键本身")
        return key
    }
    
    // 强制重新加载本地化字符串
    func reloadLocalizedStrings() {
        // 清除缓存
        cachedStrings.removeAll()
        
        // 获取当前语言
        let currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        print("重新加载本地化字符串 (语言: \(currentLanguage))")
        
        // 预加载一些常用的本地化字符串
        _ = localizedString(for: "settings_title")
        _ = localizedString(for: "language_settings")
        _ = localizedString(for: "theme_settings")
        _ = localizedString(for: "dark_mode")
        _ = localizedString(for: "light_mode")
        
        // 通知系统本地化字符串已重新加载
        NotificationCenter.default.post(name: NSNotification.Name("LocalizedStringsReloaded"), object: nil)
    }
    
    private init() {}
}

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = LocalizationManager.shared.localizedString(for: self)
        return String(format: localizedString, arguments: arguments)
    }
}

struct LocalizedStrings {
    // Tab Bar
    static var home: String { "home".localized }
    static var flavorGacha: String { "flavor_gacha".localized }
    static var me: String { "me".localized }
    
    // Home Screen
    static var letsCooking: String { "lets_cooking".localized }
    static var selectIngredients: String { "select_ingredients".localized }
    static var vegetables: String { "vegetables".localized }
    static var meats: String { "meats".localized }
    static var stapleFoods: String { "staple_foods".localized }
    static var selectKitchenware: String { "select_kitchenware".localized }
    static var recommendedRecipes: String { "recommended_recipes".localized }
    
    // 蔬菜
    static var potato: String { "potato".localized }
    static var carrot: String { "carrot".localized }
    static var tomato: String { "tomato".localized }
    static var onion: String { "onion".localized }
    static var greenPepper: String { "green_pepper".localized }
    static var eggplant: String { "eggplant".localized }
    static var spinach: String { "spinach".localized }
    static var cucumber: String { "cucumber".localized }
    static var sweetCorn: String { "sweet_corn".localized }
    static var celery: String { "celery".localized }
    static var cauliflower: String { "cauliflower".localized }
    static var broccoli: String { "broccoli".localized }
    static var bitterMelon: String { "bitter_melon".localized }
    static var pumpkin: String { "pumpkin".localized }
    static var lotusRoot: String { "lotus_root".localized }
    static var mushrooms: String { "mushrooms".localized }
    static var enokiMushrooms: String { "enoki_mushrooms".localized }
    static var shiitakeMushrooms: String { "shiitake_mushrooms".localized }
    static var oysterMushrooms: String { "oyster_mushrooms".localized }
    static var kingOysterMushrooms: String { "king_oyster_mushrooms".localized }
    
    // 肉类
    static var sausage: String { "sausage".localized }
    static var pork: String { "pork".localized }
    static var beef: String { "beef".localized }
    static var eggs: String { "eggs".localized }
    static var fish: String { "fish".localized }
    static var shrimp: String { "shrimp".localized }
    static var chicken: String { "chicken".localized }
    static var lamb: String { "lamb".localized }
    static var duck: String { "duck".localized }
    static var goose: String { "goose".localized }
    static var offal: String { "offal".localized }
    static var tripe: String { "tripe".localized }
    
    // 主食
    static var pasta: String { "pasta".localized }
    static var bread: String { "bread".localized }
    static var rice: String { "rice".localized }
    static var noodles: String { "noodles".localized }
    static var riceFlour: String { "rice_flour".localized }
    static var grains: String { "grains".localized }
    static var beans: String { "beans".localized }
    static var beanProducts: String { "bean_products".localized }
    static var tubers: String { "tubers".localized }
    static var nuts: String { "nuts".localized }
    
    // 厨具
    static var oven: String { "oven".localized }
    static var airFryer: String { "air_fryer".localized }
    static var microwave: String { "microwave".localized }
    static var riceCooker: String { "rice_cooker".localized }
    static var versatilePot: String { "versatile_pot".localized }
    
    // 食谱名称
    static var roastedPotatoPork: String { "roasted_potato_pork".localized }
    static var riceCookerChickenRice: String { "rice_cooker_chicken_rice".localized }
    
    // 食谱描述
    static var classicCombinationPotatoesPork: String { "classic_combination_potatoes_pork".localized }
    static var simpleQuickOnePotMeal: String { "simple_quick_one_pot_meal".localized }
    
    // Profile
    static var profile: String { "profile".localized }
    static var premiumMember: String { "premium_member".localized }
    static var history: String { "history".localized }
    static var myFavorites: String { "my_favorites".localized }
    static var shareRecipes: String { "share_recipes".localized }
    static var feedback: String { "feedback".localized }
    static var settings: String { "settings".localized }
    static var about: String { "about".localized }
    
    // History
    static var yearMonth: String { "year_month".localized }
    static var recentlyCooking: String { "recently_cooking".localized }
    
    // Flavor Gacha
    static var servings: String { "servings".localized }
    static var randomMatch: String { "random_match".localized }
    static var recipes: String { "recipes".localized }
    static var clickRandomMatch: String { "click_random_match".localized }
    static var dessert: String { "dessert".localized }
    
    // Settings
    static var settingsTitle: String { "settings_title".localized }
    static var languageSettings: String { "language_settings".localized }
    static var themeSettings: String { "theme_settings".localized }
    static var darkMode: String { "dark_mode".localized }
    static var lightMode: String { "light_mode".localized }
    
    // About
    static var aboutUs: String { "about_us".localized }
    static var userAgreement: String { "user_agreement".localized }
    static var privacyPolicy: String { "privacy_policy".localized }
    static var versionInfo: String { "version_info".localized }
    static var allRightsReserved: String { "all_rights_reserved".localized }
    
    // About Us Content
    static var aboutUsTitle: String { "about_us_title".localized }
    static var aboutUsDescription: String { "about_us_description".localized }
    static var feature1: String { "feature1".localized }
    static var feature1Desc: String { "feature1_desc".localized }
    static var feature2: String { "feature2".localized }
    static var feature2Desc: String { "feature2_desc".localized }
    static var feature3: String { "feature3".localized }
    static var feature3Desc: String { "feature3_desc".localized }
    
    // User Agreement
    static var userAgreementTitle: String { "user_agreement_title".localized }
    static var agreementSection1: String { "agreement_section1".localized }
    static var agreementSection1Content: String { "agreement_section1_content".localized }
    static var agreementSection2: String { "agreement_section2".localized }
    static var agreementSection2Content: String { "agreement_section2_content".localized }
    static var agreementSection3: String { "agreement_section3".localized }
    static var agreementSection3Content: String { "agreement_section3_content".localized }
    static var agreementSection4: String { "agreement_section4".localized }
    static var agreementSection4Content: String { "agreement_section4_content".localized }
    
    // Privacy Policy
    static var privacyPolicyTitle: String { "privacy_policy_title".localized }
    static var privacySection1: String { "privacy_section1".localized }
    static var privacySection1Content: String { "privacy_section1_content".localized }
    static var privacySection2: String { "privacy_section2".localized }
    static var privacySection2Content: String { "privacy_section2_content".localized }
    static var privacySection3: String { "privacy_section3".localized }
    static var privacySection3Content: String { "privacy_section3_content".localized }
    static var privacySection4: String { "privacy_section4".localized }
    static var privacySection4Content: String { "privacy_section4_content".localized }
    
    // Version Info
    static var versionInfoTitle: String { "version_info_title".localized }
    static var currentVersion: String { "current_version".localized }
    static var buildNumber: String { "build_number".localized }
    static var developer: String { "developer".localized }
    
    // About Page
    static var legalInfo: String { "legal_info".localized }
    static var termsOfService: String { "terms_of_service".localized }
    static var openSourceLicenses: String { "open_source_licenses".localized }
    static var supportInfo: String { "support_info".localized }
    static var contactUs: String { "contact_us".localized }
    static var rateApp: String { "rate_app".localized }
    static var shareApp: String { "share_app".localized }
    
    // Content for legal pages
    // Content for legal pages
    static var termsOfServiceContent: String { "terms_of_service_content".localized }
    static var privacyPolicyContent: String { "privacy_policy_content".localized }
    static var openSourceLicensesContent: String { "open_source_licenses_content".localized }
    
    // Favorites
    static var favorited: String { "favorited".localized }
    static var unfavorited: String { "unfavorited".localized }
    static var noFavorites: String { "no_favorites".localized }
    static var noFavoritesDescription: String { "no_favorites_description".localized }
    static var views: String { "views".localized }
    
    // Search
    static var searchRecipes: String { "search_recipes".localized }
    static var searchingVideos: String { "searching_videos".localized }
    static var basedOnSelection: String { "based_on_selection".localized }
    static var pleaseSelectFirst: String { "please_select_first".localized }
    static var noVideosFound: String { "no_videos_found".localized }
    static var tryOtherIngredients: String { "try_other_ingredients".localized }
    static var searchingCookingVideos: String { "searching_cooking_videos".localized }
    static var tryRandomMatchAgain: String { "try_random_match_again".localized }
    static var searchingForRecipes: String { "searching_for_recipes".localized }
    
    // Welcome Screen
    static var welcomeSubtitle: String { "welcome_subtitle".localized }
    static var welcomeLoading: String { "welcome_loading".localized }
    
    // Premium
    static var premium: String { "premium".localized }
    static var premiumTitle: String { "premium_title".localized }
    static var premiumSubtitle: String { "premium_subtitle".localized }
    static var choosePlan: String { "choose_plan".localized }
    static var freeTrialTitle: String { "free_trial_title".localized }
    static var halfYearTitle: String { "half_year_title".localized }
    static var fullYearTitle: String { "full_year_title".localized }
    static var free: String { "free".localized }
    static var oneMonth: String { "one_month".localized }
    static var sixMonths: String { "six_months".localized }
    static var oneYear: String { "one_year".localized }
    static var bestValue: String { "best_value".localized }
    static var startFreeTrial: String { "start_free_trial".localized }
    static var subscribe: String { "subscribe".localized }
    static var subscriptionTerms: String { "subscription_terms".localized }
    static var close: String { "close".localized }
    static var subscriptionSuccess: String { "subscription_success".localized }
    static var freeTrialActivated: String { "free_trial_activated".localized }
    static var halfYearSubscribed: String { "half_year_subscribed".localized }
    static var fullYearSubscribed: String { "full_year_subscribed".localized }
    static var ok: String { "ok".localized }
    
    // Avatar
    static var changeAvatar: String { "change_avatar".localized }
    static var choosePhoto: String { "choose_photo".localized }
    static var takePhoto: String { "take_photo".localized }
    static var cancel: String { "cancel".localized }
    
    // Login/Register
    static var login: String { "login".localized }
    static var register: String { "register".localized }
    static var loginSubtitle: String { "login_subtitle".localized }
    static var registerSubtitle: String { "register_subtitle".localized }
    static var fullName: String { "full_name".localized }
    static var email: String { "email".localized }
    static var password: String { "password".localized }
    static var confirmPassword: String { "confirm_password".localized }
    static var noAccount: String { "no_account".localized }
    static var haveAccount: String { "have_account".localized }
    static var notice: String { "notice".localized }
    static var loginFailed: String { "login_failed".localized }
    static var passwordMismatch: String { "password_mismatch".localized }
    static var passwordTooShort: String { "password_too_short".localized }
    static var invalidEmail: String { "invalid_email".localized }
    static var emailAlreadyExists: String { "email_already_exists".localized }
    static var logout: String { "logout".localized }
    static var processing: String { "processing".localized }
    
    // Login/Register additional strings
    static var welcomeBack: String { "welcome_back".localized }
    static var createNewAccount: String { "create_new_account".localized }
    static var alreadyHaveAccount: String { "already_have_account".localized }
    static var dontHaveAccount: String { "dont_have_account".localized }
    static var loginFailedMessage: String { "login_failed_message".localized }
    static var registrationFailedMessage: String { "registration_failed_message".localized }
    static var passwordsDontMatch: String { "passwords_dont_match".localized }
    static var passwordMinLength: String { "password_min_length".localized }
    static var invalidEmailFormat: String { "invalid_email_format".localized }
    static var alertTitle: String { "alert_title".localized }
    static var alertOk: String { "alert_ok".localized }
    static var registrationFailed: String { "registration_failed".localized }
    
    // 收藏数量
    static func favoriteCount(_ count: Int) -> String {
        return "favorite_count".localized(with: count)
    }
    
    // 收藏时间
    static func favoriteTime(_ time: String) -> String {
        return "favorite_time".localized(with: time)
    }
}
