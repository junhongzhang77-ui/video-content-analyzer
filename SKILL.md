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
  - faster-whisper (免费语音转文字)
---

# 视频内容分析器（免费版）

> ⚠️ **注意**：这是 video-content-analyzer 的免费版本，使用 faster-whisper 替代付费的 Whisper API。

自动下载视频并用 AI 分析内容，支持 B站/抖音/YouTube 等平台，提取语音文案，输出综合分析报告。

## 功能

1. **视频下载** - 支持B站、抖音、YouTube等主流平台
2. **自动获取数据** - 自动提取视频标题、播放量、互动数据
3. **语音转写** - 用 faster-whisper 免费转写为文字
4. **内容分析** - AI分析视频结构、节奏、钩子
5. **批量分析** - 支持多个视频链接批量分析
6. **报告导出** - 自动保存分析报告到本地

## 前置要求

### 必须安装的工具

```bash
# Mac: 安装 ffmpeg
brew install ffmpeg

# 安装 yt-dlp (视频下载)
pip3 install --break-system-packages yt-dlp

# 安装 faster-whisper (免费语音转写)
pip3 install --break-system-packages faster-whisper
```

### faster-whisper 首次使用

首次使用会自动下载模型（small中文模型，约500MB）

---

## 使用方法

### 输入

用户提供视频链接，例如：
- B站: `https://www.bilibili.com/video/BV1xuPYzcEdo`
- 抖音: `https://www.douyin.com/video/xxx`
- YouTube: `https://www.youtube.com/watch?v=xxx`

### 输出

完整的综合分析报告，包括：
1. 📊 视频数据（标题、播放、点赞、投币、收藏）
2. 📝 完整文案（语音转写）
3. 🎬 视频结构分析（章节/时间节点）
4. 🪝 钩子分析
5. ⏱️ 节奏分析
6. 💡 爆款原因拆解
7. 🎯 可复制策略

**报告会自动保存到 `~/.openclaw/workspace/video-analysis/` 目录下**

---

## 工作流程

```
1. 输入视频链接
        ↓
2. 自动提取 BV号/视频ID
        ↓
3. 获取视频基本信息（标题、播放、互动数据）
        ↓
4. yt-dlp 下载视频
        ↓
5. faster-whisper 转写语音
        ↓
6. AI 分析 (文案+数据)
        ↓
7. 输出综合报告 + 保存到文件
```

### 支持的输入格式

- B站: `https://www.bilibili.com/video/BV1xuPYzcEdo` 或 `BV1xuPYzcEdo`
- 抖音: `https://www.douyin.com/video/xxx`
- YouTube: `https://www.youtube.com/watch?v=xxx`

---

## 命令行示例

### 1. Python 转写脚本

```python
import re
from faster_whisper import WhisperModel

def extract_bvid(url):
    """从B站链接提取BV号"""
    match = re.search(r'BV[\w]+', url)
    return match.group(0) if match else url

def transcribe_video(video_path, language='zh'):
    """转写视频"""
    model = WhisperModel('small', device='cpu', compute_type='int8')
    segments, info = model.transcribe(video_path, language=language)
    return ' '.join([seg.text for seg in segments])

# 使用
bvid = extract_bvid('https://www.bilibili.com/video/BV1xuPYzcEdo')
text = transcribe_video('/tmp/video.mp4')
print(text)
```

### 2. 获取B站视频数据

```python
import requests

def get_bilibili_info(bvid):
    """获取B站视频信息"""
    url = f'https://api.bilibili.com/x/web-interface/view?bvid={bvid}'
    data = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'}).json()['data']
    stat = data['stat']
    return {
        'title': data['title'],
        'author': data['owner']['name'],
        'duration': data['duration'],
        'view': stat['view'],
        'like': stat['like'],
        'coin': stat['coin'],
        'favorite': stat['favorite']
    }

# 使用
info = get_bilibili_info('1xuPYzcEdo')
print(info)
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

[faster-whisper转写的完整语音文案]

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
2. 💰 **费用** - 完全免费（faster-whisper + 免费AI）
3. ⏱️ **时间** - 完整分析需要 3-5 分钟（取决于视频长度）
4. 📏 **长度** - 建议视频时长 < 30 分钟
5. 🔐 **版权** - 仅供学习分析使用，勿用于商业目的

---

## 故障排除

### 视频下载失败
- 检查网络连接
- 尝试使用代理
- B站可能需要 Cookie 认证

### faster-whisper 转写效果差
- 首次使用会自动下载模型（需等待）
- 检查音频质量
- 可尝试更换模型（base/small/medium/large）

### ffmpeg 问题
- 确认 ffmpeg 已安装: `ffmpeg -version`
- Mac用户: `brew install ffmpeg`

---

## 免费 AI 分析提示词

将文案发给 Kimi/智谱清言：

> 请分析以下短视频的文案和数据，输出结构分析、钩子分析、爆款原因分析：
> 
> **视频数据**：
> - 标题：[标题]
> - 播放：[播放量]
> - 点赞：[点赞数]
> - 投币：[投币数]
> - 收藏：[收藏数]
> 
> **语音文案**：
> [粘贴文案]
> 
> 请按以下格式输出：
> 1. 视频结构（时间线+内容）
> 2. 钩子设计分析
> 3. 爆款原因拆解（核心爆点+辅助因素）
> 4. 可复制策略（普通人可抄程度）

---

## 故障排除

### 模型下载慢/失败
- 首次使用需下载模型（约500MB）
- 可尝试更换国内源或代理
- 模型可选：base(140MB)/small(500MB)/medium(1.5GB)/large(3GB)

### 视频下载失败
- 检查网络连接
- 尝试使用代理
- B站可能需要 Cookie 认证

### faster-whisper 转写效果差
- 首次使用会自动下载模型（需等待）
- 检查音频质量
- 可尝试更换模型（base/small/medium/large）

### ffmpeg 问题
- 确认 ffmpeg 已安装: `ffmpeg -version`
- Mac用户: `brew install ffmpeg`

---

## 批量分析

### 获取B站热门TOP视频

```python
import requests

def get_bilibili_top(ps=20, pn=1):
    """获取B站热门视频"""
    url = f'https://api.bilibili.com/x/web-interface/popular?ps={ps}&pn={pn}'
    data = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'}).json()['data']['list']
    return [{'bvid': v['bvid'], 'title': v['title'], 'duration': v['duration']} for v in data]

# 获取TOP20
tops = get_bilibili_top(20)
for v in tops:
    print(f"https://www.bilibili.com/video/{v['bvid']}")
```

### 批量分析示例

```python
# 批量分析TOP5视频
video_links = [
    "https://www.bilibili.com/video/BV1xxx",
    "https://www.bilibili.com/video/BV2xxx",
    "https://www.bilibili.com/video/BV3xxx",
]

for link in video_links:
    # 1. 获取数据
    # 2. 下载视频
    # 3. 转写
    # 4. 分析
    # 5. 保存报告
    pass
```

---

## 一键安装脚本

```bash
#!/bin/bash
# install.sh - 一键安装依赖

echo "📦 安装视频分析工具..."

# ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "安装 ffmpeg..."
    brew install ffmpeg
fi

# yt-dlp
echo "安装 yt-dlp..."
pip3 install --break-system-packages yt-dlp

# faster-whisper
echo "安装 faster-whisper..."
pip3 install --break-system-packages faster-whisper

# 创建输出目录
mkdir -p ~/.openclaw/workspace/video-analysis

echo "✅ 安装完成！"
echo "使用方式：发送视频链接给我即可分析"
```
