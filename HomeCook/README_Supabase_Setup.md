# Supabase 集成设置指南

## 概述
本项目已集成 Supabase 作为后端服务，用于处理用户认证和数据存储。

## Supabase 配置信息
- **项目 URL**: https://acntswpecnwgvrhpfhcq.supabase.co
- **API Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjbnRzd3BlY253Z3ZyaHBmaGNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwMzQwMTcsImV4cCI6MjA2OTYxMDAxN30.vBHBxhxr0Ln1im885jCto3UG7aWrtlQNT76wTPR6sG0

## 在 Xcode 中添加 Supabase 依赖

### 方法 1: 使用 Swift Package Manager (推荐)

1. 在 Xcode 中打开项目
2. 选择 **File** → **Add Package Dependencies...**
3. 在搜索框中输入: `https://github.com/supabase/supabase-swift`
4. 点击 **Add Package**
5. 选择以下模块添加到项目中:
   - `Supabase`
   - `Auth`
   - `PostgREST`
   - `Storage`
   - `Realtime`
6. 点击 **Add Package** 完成添加

### 方法 2: 手动添加依赖

如果方法 1 不工作，可以手动编辑项目文件:

1. 在项目导航器中选择项目根目录
2. 选择项目 target
3. 点击 **Package Dependencies** 标签
4. 点击 **+** 按钮
5. 输入 URL: `https://github.com/supabase/supabase-swift`
6. 选择版本规则 (建议使用 "Up to Next Major Version")
7. 添加所需的产品模块

## 数据库表结构

### users 表
```sql
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 启用行级安全性
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 创建策略：用户只能查看和修改自己的数据
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);
```

## 已实现的功能

### 1. 用户认证
- ✅ 用户注册 (使用邮箱和密码)
- ✅ 用户登录
- ✅ 用户登出
- ✅ 会话管理
- ✅ 自动登录状态恢复

### 2. 用户管理
- ✅ 用户信息存储
- ✅ 用户资料更新
- ✅ 本地缓存用户数据

### 3. 安全特性
- ✅ 行级安全性 (RLS)
- ✅ JWT 令牌认证
- ✅ 安全的密码处理

## 文件结构

```
HomeCook/
├── Services/
│   └── SupabaseService.swift      # Supabase 服务配置和 API 调用
├── Utils/
│   └── UserManager.swift          # 用户管理器 (集成 Supabase)
├── Views/Components/
│   └── LoginRegisterView.swift    # 登录/注册界面
└── Views/
    └── ProfileView.swift          # 用户资料页面
```

## 使用说明

### 初始化 Supabase
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://acntswpecnwgvrhpfhcq.supabase.co")!,
    supabaseKey: "your-anon-key"
)
```

### 用户注册
```swift
let userManager = UserManager.shared
await userManager.register(fullName: "用户名", email: "user@example.com", password: "password")
```

### 用户登录
```swift
let userManager = UserManager.shared
await userManager.login(email: "user@example.com", password: "password")
```

## 故障排除

### 常见问题

1. **编译错误: "No such module 'Supabase'"**
   - 确保已正确添加 Supabase 依赖
   - 清理构建文件夹 (Product → Clean Build Folder)
   - 重新构建项目

2. **网络请求失败**
   - 检查网络连接
   - 确认 Supabase 项目 URL 和 API Key 正确
   - 检查 Supabase 项目是否处于活跃状态

3. **认证失败**
   - 确认用户邮箱和密码正确
   - 检查 Supabase 认证设置
   - 查看 Supabase 控制台的认证日志

### 调试技巧

1. 启用详细日志记录
2. 使用 Supabase 控制台监控 API 调用
3. 检查网络请求和响应

## 下一步开发

- [ ] 添加邮箱验证功能
- [ ] 实现密码重置功能
- [ ] 添加社交登录 (Google, Apple)
- [ ] 实现用户头像上传到 Supabase Storage
- [ ] 添加用户偏好设置存储

## 支持

如果遇到问题，请参考:
- [Supabase Swift 文档](https://github.com/supabase/supabase-swift)
- [Supabase 官方文档](https://supabase.com/docs)