---
name: video-content-analyzer-free
description: 下载视频并用AI分析内容（免费版）- 支持B站/抖音/YouTube等平台，提取语音内容，AI分析视频结构
version: "1.0.0"
author: laipishe
license: MIT
category: marketing
tags:
  - 视频分析
  - 内容理解
  - 语音转文字
  - B站
  - 抖音
  - YouTube
  - 免费
department: Marketing

allowed-tools: Exec

models:
  recommended:
    - minimax/MiniMax-M2.5
    - claude-sonnet-4
  compatible:
    - gpt-4o
    - kimix
    - zhipu

languages:
  - zh

capabilities:
  - video_download
  - audio_extraction
  - speech_to_text_free
  - content_analysis

related_skills:
  - video-content-analyzer

dependencies:
  - yt-dlp (视频下载)
  - ffmpeg (音频提取)
  - coqui-stt (免费语音转文字)
---

# 视频内容分析器（免费版）

> ⚠️ **注意**：这是 video-content-analyzer 的免费版本，使用 Coqui 替代付费的 Whisper API。

自动下载视频并用 AI 分析内容，支持 B站/抖音/YouTube 等平台，提取语音文案，输出综合分析报告。

## 功能

1. **视频下载** - 支持B站、抖音、YouTube等主流平台
2. **音频提取** - 用 ffmpeg 提取视频中的音频
3. **语音转写** - 用 Coqui STT 免费转写为文字
4. **内容分析** - AI分析视频结构、节奏、钩子

## 前置要求

### 必须安装的工具

```bash
# Mac: 安装 ffmpeg
brew install ffmpeg

# 安装 yt-dlp (视频下载)
pip3 install --break-system-packages yt-dlp

# 安装 Coqui STT (免费语音转写)
pip3 install coqui-stt

# 下载 Coqui 模型 (首次使用)
coqui-stt --model_dir ~/.coqui
```

### Coqui 模型下载

首次使用需要下载模型：

```bash
# 创建模型目录
mkdir -p ~/.coqui

# 下载预训练模型 (英文+中文支持)
# 模型地址: https://github.com/coqui-ai/STT-models
# 推荐使用: vosk-model-cn for Chinese
```

---

## 使用方法

### 输入

用户提供视频链接，例如：
- B站: `https://www.bilibili.com/video/BV1xuPYzcEdo`
- 抖音: `https://www.douyin.com/video/xxx`
- YouTube: `https://www.youtube.com/watch?v=xxx`

### 输出

完整的综合分析报告，包括：
1. 📝 完整文案（语音转写）
2. 🎬 视频结构分析（章节/时间节点）
3. 🪝 钩子分析
4. ⏱️ 节奏分析
5. 💡 内容总结

**报告会自动保存到 `~/.openclaw/workspace/video-analysis/` 目录下**，文件名为 `{视频标题}_{日期}.md`

---

## 工作流程

```
1. 输入视频链接
        ↓
2. yt-dlp 下载视频
        ↓
3. ffmpeg 提取音频
        ↓
4. Coqui STT 转写语音
        ↓
5. AI 分析 (文案)
        ↓
6. 输出综合报告
```

---

## 命令行示例

### 1. 下载视频 + 提取音频

```bash
# 下载B站视频（仅音频）
yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" "https://www.bilibili.com/video/BV1xuPYzcEdo"

# 下载视频（最佳画质）
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "%(title)s.%(ext)s" "https://www.bilibili.com/video/BV1xuPYzcEdo"

# 提取音频
ffmpeg -i input.mp4 -vn -acodec libmp3lame -q:a 2 output.mp3
```

### 2. Coqui 转写

```bash
# 使用 Coqui 转写音频
coqui-stt --model models/coqui-model-cn --scorer models/coqui-scorer-cn audio.mp3 > output.txt

# 或使用 Python API
python3 -c "
from coqui_stt import Model

model = Model('models/coqui-model-cn')
transcript = model.stt('audio.mp3')
print(transcript)
"
```

---

## 脚本工具

### download-analyze.sh

一键下载+转写+分析脚本：

```bash
#!/bin/bash
# 用法: ./download-analyze.sh <视频URL> [输出目录]

URL="$1"
OUTPUT_DIR="${2:-./analysis}"

mkdir -p "$OUTPUT_DIR"

echo "📥 获取视频信息..."
TITLE=$(yt-dlp --get-title "$URL")
echo "📺 视频: $TITLE"

echo "⬇️ 下载视频..."
yt-dlp -f "best" --output "$OUTPUT_DIR/video.%(ext)s" "$URL"

echo "🎵 提取音频..."
ffmpeg -i "$OUTPUT_DIR/video."* -vn -acodec libmp3lame -q:a 2 "$OUTPUT_DIR/audio.mp3" -y

echo "📝 转写语音 (Coqui)..."
coqui-stt --model ~/.coqui/model --scorer ~/.coqui/scorer "$OUTPUT_DIR/audio.mp3" > "$OUTPUT_DIR/transcript.txt"

echo "✅ 完成！"
echo "📁 输出目录: $OUTPUT_DIR"
echo ""
echo "下一步: 使用免费 AI (Kimi/智谱) 分析文案"
```

---

## 输出模板

```markdown
# 📹 视频综合分析报告

**视频**: [标题]
**链接**: [URL]
**时长**: [时长]
**平台**: [B站/抖音/YouTube]
**分析日期**: [日期]

---

## 📝 完整文案

[Coqui转写的完整语音文案]

---

## 🎬 视频结构

| 时间 | 内容 | 类型 |
|------|------|------|
| 0:00-0:30 | xxx | 钩子 |
| 0:30-2:00 | xxx | 铺垫 |
| 2:00-4:00 | xxx | 核心内容 |
| 4:00-5:00 | xxx | 结尾 |
| ... | ... | ... |

---

## 🪝 钩子分析

[开头3秒的钩子设计分析]

---

## ⏱️ 节奏分析

[视频节奏把控分析]

---

## 💡 总结

### 核心亮点
[视频的核心内容和亮点]

### 可复用点
[可以借鉴的创作手法]
```

---

## 注意事项

1. 📡 **网络** - 下载视频需要稳定的网络，B站建议使用 Cookie 认证
2. 💰 **费用** - 完全免费（Coqui + 免费AI）
3. ⏱️ **时间** - 完整分析需要 5-10 分钟（取决于视频长度）
4. 📏 **长度** - 建议视频时长 < 30 分钟
5. 🔐 **版权** - 仅供学习分析使用，勿用于商业目的

---

## 故障排除

### 视频下载失败
- 检查网络连接
- 尝试使用代理
- B站可能需要 Cookie 认证

### Coqui 转写效果差
- 确认模型支持中文（使用 coqui-model-cn）
- 检查音频质量
- 尝试调整音频音量

### ffmpeg 问题
- 确认 ffmpeg 已安装: `ffmpeg -version`
- Mac用户: `brew install ffmpeg`

---

## 免费 AI 分析提示词

将文案发给 Kimi/智谱清言：

> 请分析以下短视频的文案，输出结构分析、钩子分析、节奏分析：
> 
> **语音文案**：
> [粘贴文案]
> 
> 请按以下格式输出：
> 1. 视频结构（时间线+内容）
> 2. 钩子设计分析
> 3. 节奏把控分析
> 4. 总结与可复用点
