# YouTube API 配置指南

## 概述
HomeCook应用使用YouTube Data API v3来搜索真实的烹饪视频。为了使用此功能，您需要获取YouTube Data API密钥并进行配置。

## 获取YouTube API密钥

### 1. 创建Google Cloud项目
1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 登录您的Google账户
3. 创建新项目或选择现有项目

### 2. 启用YouTube Data API v3
1. 在Google Cloud Console中，导航到"API和服务" > "库"
2. 搜索"YouTube Data API v3"
3. 点击API并启用它

### 3. 创建API密钥
1. 导航到"API和服务" > "凭据"
2. 点击"创建凭据" > "API密钥"
3. 复制生成的API密钥

### 4. 配置API密钥限制（推荐）
1. 点击刚创建的API密钥进行编辑
2. 在"应用程序限制"中选择"iOS应用"
3. 添加您的应用包标识符
4. 在"API限制"中选择"限制密钥"，然后选择"YouTube Data API v3"

## 在应用中配置API密钥

### 方法1：直接修改代码（开发测试用）
在 `HomeCook/Services/YouTubeService.swift` 文件中找到以下行：
```swift
private let apiKey = "AIzaSyClg2PfN8sDmxijNudJszFTxYsFsbkonWE"
```

将其替换为您的真实API密钥：
```swift
private let apiKey = "您的真实API密钥"
```

### 方法2：使用配置文件（生产环境推荐）
1. 创建一个名为 `Config.plist` 的文件
2. 添加以下内容：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>YouTubeAPIKey</key>
    <string>您的真实API密钥</string>
</dict>
</plist>
```

3. 修改YouTubeService.swift以从配置文件读取：
```swift
private let apiKey: String = {
    guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let key = plist["YouTubeAPIKey"] as? String else {
        return ""
    }
    return key
}()
```

## API配额和限制

### 默认配额
- 每天10,000个单位
- 搜索操作：100单位/请求
- 视频详情操作：1单位/请求

### 优化建议
1. **缓存结果**：避免重复搜索相同内容
2. **限制搜索频率**：添加搜索间隔限制
3. **批量获取视频详情**：一次请求获取多个视频的详情

## 功能特性

### 多语言搜索支持
应用根据当前语言设置搜索对应语言的视频：
- 🇺🇸 英语：搜索英语烹饪视频
- 🇨🇳 中文：搜索中文烹饪视频
- 🇯🇵 日语：搜索日语烹饪视频
- 🇰🇷 韩语：搜索韩语烹饪视频
- 🇩🇪 德语：搜索德语烹饪视频
- 🇪🇸 西班牙语：搜索西班牙语烹饪视频
- 🇫🇷 法语：搜索法语烹饪视频
- 🇷🇺 俄语：搜索俄语烹饪视频

### 智能搜索算法
1. **食材关键词**：基于用户选择的食材构建搜索查询
2. **语言特定关键词**：每种语言都有专门的烹饪相关关键词
3. **质量筛选**：优先选择中等时长、高清质量的视频
4. **点赞排序**：按点赞数排序，返回最受欢迎的前6个视频

### 视频信息显示
- ✅ 真实的视频标题和描述
- ✅ 频道名称和发布时间
- ✅ 视频时长和点赞数
- ✅ 高质量缩略图预览
- ✅ 直接跳转YouTube观看

## 故障排除

### 常见错误
1. **API密钥无效**：检查密钥是否正确复制
2. **配额超限**：等待配额重置或申请增加配额
3. **API未启用**：确保在Google Cloud Console中启用了YouTube Data API v3
4. **网络错误**：检查网络连接和防火墙设置

### 调试建议
1. 在Xcode控制台查看详细错误信息
2. 验证API密钥在Google Cloud Console中的状态
3. 检查API调用的请求参数是否正确

## 安全注意事项

### 保护API密钥
1. **不要提交到版本控制**：将包含API密钥的文件添加到.gitignore
2. **使用环境变量**：在CI/CD中使用环境变量注入API密钥
3. **定期轮换密钥**：定期更新API密钥以提高安全性
4. **限制密钥权限**：只授予必要的API访问权限

### 示例.gitignore条目
```
# API配置文件
Config.plist
APIKeys.swift

# 环境配置
.env
*.env
```

## 支持和帮助

如果您在配置过程中遇到问题，请参考：
- [YouTube Data API v3 官方文档](https://developers.google.com/youtube/v3)
- [Google Cloud Console 帮助](https://cloud.google.com/docs)
- [iOS应用API密钥最佳实践](https://developer.apple.com/documentation/security)