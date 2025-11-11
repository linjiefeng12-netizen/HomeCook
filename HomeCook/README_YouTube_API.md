# YouTube API 配置说明

## 如何获取 YouTube Data API 密钥

为了使用真实的YouTube搜索功能，您需要从Google Cloud Console获取YouTube Data API密钥。

### 步骤 1: 创建Google Cloud项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 登录您的Google账户
3. 创建新项目或选择现有项目

### 步骤 2: 启用YouTube Data API v3

1. 在Google Cloud Console中，导航到"API和服务" > "库"
2. 搜索"YouTube Data API v3"
3. 点击进入并启用该API

### 步骤 3: 创建API密钥

1. 导航到"API和服务" > "凭据"
2. 点击"创建凭据" > "API密钥"
3. 复制生成的API密钥

### 步骤 4: 配置API密钥限制（推荐）

1. 点击刚创建的API密钥进行编辑
2. 在"应用限制"中选择"iOS应用"
3. 添加您的应用包标识符
4. 在"API限制"中选择"限制密钥"，然后选择"YouTube Data API v3"

### 步骤 5: 在应用中配置API密钥

打开 `HomeCook/Services/YouTubeService.swift` 文件，找到以下行：

```swift
private let apiKey = "AIzaSyDummy_Replace_With_Real_API_Key"
```

将其替换为您的真实API密钥：

```swift
private let apiKey = "您的真实API密钥"
```

## 重要注意事项

1. **安全性**: 不要将API密钥提交到公共代码仓库
2. **配额限制**: YouTube Data API有每日配额限制，请合理使用
3. **费用**: 超出免费配额后可能产生费用
4. **备用方案**: 如果没有配置API密钥，应用会使用模拟数据

## 测试配置

配置完成后，在Home页面：
1. 选择一些食材（如土豆、鸡肉等）
2. 点击"搜索烹饪视频"按钮
3. 如果配置正确，将显示真实的YouTube搜索结果

## 故障排除

- **错误: "无效的YouTube API密钥"**: 检查API密钥是否正确复制
- **错误: "网络连接错误"**: 检查网络连接和API配额
- **错误: "数据解析错误"**: 可能是API响应格式变化，请检查API版本

## 模拟数据模式

如果不配置真实API密钥，应用会自动使用模拟数据模式，生成与选择食材相关的虚拟视频内容，用于演示和测试。