# 语音朗读助手 📖🎤

一款带**情感**的 PDF 和 Word 文档朗读 Android App。

基于 Flutter + Azure 语音服务构建，支持中英文混读，可切换多种情感风格。

## ✨ 功能特点

- 📂 **文件支持**：打开并朗读 PDF (.pdf) 和 Word (.docx / .doc) 文档
- 🎭 **情感朗读**：8 种情感风格（平静、愉快、悲伤、愤怒、害怕、安慰、严肃、共情）
- 🗣️ **多声音选择**：多个中文发音人（晓晓、云希、云扬等）
- ⏱️ **语速调节**：0.5x ~ 2.0x 倍速
- 📍 **段落高亮**：当前朗读段落自动高亮显示
- 💾 **进度保存**：自动保存阅读进度，下次继续
- 🎨 **Material Design 3**：支持深色模式

## 📱 下载 APK

通过 GitHub Actions 自动构建：

1. 进入仓库的 **Actions** 选项卡
2. 选择最新的 **Build Android APK** 工作流
3. 下载 **voice-reader-apk** 构件
4. 解压后安装 `.apk` 文件到手机

或点击下方按钮手动触发构建：

[![Build APK](https://github.com/your-username/voice-reader/actions/workflows/build_apk.yml/badge.svg)](https://github.com/your-username/voice-reader/actions/workflows/build_apk.yml)

> **注意**：首次安装 APK 时，手机可能会提示"未知来源应用"，请在设置中允许安装。

## 🔧 使用前配置

首次使用需要配置 **Azure 语音服务**密钥（有免费额度）：

1. 打开 App → 点击右上角 ⚙️ 设置
2. 申请 Azure 密钥（免费）：
   - 访问 [Azure Portal](https://portal.azure.com)
   - 创建 **语音服务** 资源
   - 选择 **免费层 F0**（每月 50 万字符，个人使用完全足够）
   - 获取 **密钥** 和 **区域**
3. 填入 App 设置页面，点击保存

### 情感风格说明

| 风格 | 适用场景 | Emoji |
|------|----------|-------|
| 平静 😌 | 叙述、说明、新闻 | 日常阅读推荐 |
| 愉快 😊 | 正面内容、故事 | 小说、趣文 |
| 悲伤 😢 | 感伤内容 | 抒情散文 |
| 愤怒 😠 | 激烈内容 | 辩论、批判 |
| 害怕 😨 | 悬疑内容 | 惊险小说 |
| 安慰 🤗 | 温馨内容 | 温情故事 |
| 严肃 🧐 | 正式内容 | 论文、报告 |
| 共情 💛 | 情感内容 | 感人故事 |

## 🏗️ 技术架构

- **框架**：Flutter (Dart)
- **语音引擎**：Microsoft Azure 认知服务 - 语音合成 (TTS)
- **PDF 解析**：Syncfusion Flutter PDF
- **Word 解析**：Archive + XML 解析
- **状态管理**：Riverpod
- **音频播放**：just_audio
- **构建系统**：GitHub Actions (CI/CD)

## 🚀 本地开发

```bash
# 1. 安装 Flutter SDK (3.27+)
# 2. 克隆仓库
git clone https://github.com/your-username/voice-reader.git
cd voice-reader

# 3. 获取依赖
flutter pub get

# 4. 运行（需要连接设备或模拟器）
flutter run

# 5. 构建 APK
flutter build apk --release
```

## 📄 许可

本项目仅供个人学习和使用。需自行申请 Azure 语音服务 API。

---

**提示**：使用前请确保手机已连接网络（云端 TTS 需要网络连接）。
