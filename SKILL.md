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
- TikTok: `https://www.tiktok.com/@xxx/video/xxx`
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
- TikTok: `https://www.tiktok.com/@xxx/video/xxx`
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

---

## 🎬 基本信息

| 字段 | 内容 | 字段 | 内容 |
|:----:|:-----|:----:|:-----|
| **标题** | [标题] | **链接** | [URL] |
| **作者** | [作者] | **时长** | [时长] |
| **平台** | [B站/抖音/YouTube] | **发布日期** | [日期] |

---

## 📊 数据表现

### 核心指标

| 指标 | 数值 | 占比 | 趋势 |
|:----:|:----:|:----:|:----:|
| 播放 | 100万 | 100% | 📈 |
| 点赞 | 5万 | 5% | 📈 |
| 投币 | 1万 | 1% | 📈 |
| 收藏 | 2万 | 2% | 📈 |
| 分享 | 0.5万 | 0.5% | 📈 |

### 互动漏斗

```
播放 ────████████████──── 100万
点赞 ────███──────────── 5万   (5%)
投币 ────█────────────── 1万   (1%)
收藏 ────██────────────── 2万   (2%)
```

### 互动比率雷达图

| 维度 | 数值 | 等级 |
|:----:|:----:|:----:|
| 点赞率 | 5% | ⭐⭐⭐⭐⭐ |
| 投币率 | 1% | ⭐⭐ |
| 收藏率 | 2% | ⭐⭐⭐ |
| 分享率 | 0.5% | ⭐ |

---

## 📝 语音文案

> [转写的完整文案，如果太长可省略中间部分]
> 
> **文案长度**：约 500 字
> **语速**：约 150 字/分钟

---

## 🎬 视频结构

| 时间段 | 时长 | 内容摘要 | 类型 | 评分 |
|:------:|:----:|:--------|:-----|:----:|
| 0:00-0:30 | 30s | 开场钩子 | 🪝 钩子 | ⭐⭐⭐⭐⭐ |
| 0:30-1:00 | 30s | 背景铺垫 | 📋 铺垫 | ⭐⭐⭐ |
| 1:00-3:00 | 2min | 核心内容 | 💎 干货 | ⭐⭐⭐⭐ |
| 3:00-3:30 | 30s | 总结结尾 | 🎯 结尾 | ⭐⭐⭐⭐ |

### 结构饼图

```
███ 钩子 20%
████████ 铺垫 30%
████████████ 核心 40%
███ 结尾 10%
```

---

## 🪝 钩子分析

### 开头3秒

| 元素 | 效果 | 评分 |
|:-----|:-----|:----:|
| [视觉/听觉钩子] | [描述] | ⭐⭐⭐⭐⭐ |

### 核心吸引力

| 类型 | 描述 |
|:-----|:-----|
| **情感钩子** | [哭/笑/感动] |
| **利益钩子** | [学到了/干货] |
| **好奇钩子** | [想知道结果] |

---

## ⏱️ 节奏分析

### 时间线热力图

| 区间 | 密度 | 内容密度 |
|:----:|:----:|:--------:|
| 0:00-0:30 | 🔥🔥🔥🔥🔥 | 高密度 |
| 0:30-1:00 | 🔥🔥🔥 | 中密度 |
| 1:00-2:00 | 🔥🔥🔥🔥 | 高密度 |
| 2:00-3:00 | 🔥🔥 | 低密度 |

### 节奏评估

| 指标 | 数值 | 评价 |
|:----:|:----:|:-----|
| 总时长 | 3:30 | 适中 |
| 有效内容比 | 90% | 优秀 |
| 节奏得分 | 8/10 | 良好 |

---

## 🔥 爆款原因拆解

### 核心爆点排行

| 排名 | 爆点 | 类型 | 强度 |
|:----:|:-----|:-----|:----:|
| 🥇 | [爆点1] | [反转/情感/干货] | ⭐⭐⭐⭐⭐ |
| 🥈 | [爆点2] | [情绪/话题] | ⭐⭐⭐⭐ |
| 🥉 | [爆点3] | [技巧/方法] | ⭐⭐⭐ |

### 爆款元素分布

```
██████████ 情绪价值  50%
██████     实用干货  30%
██         IP热度   10%
██         时效热点  10%
```

### 成功因素分析

| 维度 | 得分 | 说明 |
|:----:|:----:|:-----|
| 标题吸引力 | 9/10 | [亮点] |
| 内容质量 | 8/10 | [亮点] |
| 互动设计 | 7/10 | [亮点] |
| 发布时间 | 8/10 | [亮点] |

---

## 💡 可复制策略

### 立即可用

| 序号 | 策略 | 难度 | 预期效果 |
|:----:|:-----|:----:|:--------:|
| 1 | [具体做法] | ⭐⭐ | 高 |
| 2 | [具体做法] | ⭐⭐⭐ | 中 |
| 3 | [具体做法] | ⭐⭐⭐⭐ | 高 |

### 执行清单

- [ ] 模仿开头3秒钩子
- [ ] 优化标题结构
- [ ] 控制时长在3分钟内
- [ ] 添加互动引导

---

## 📈 综合评分

| 维度 | 得分 |
|:-----|:----:|
| 播放量潜力 | ⭐⭐⭐⭐⭐ |
| 互动率 | ⭐⭐⭐⭐ |
| 内容质量 | ⭐⭐⭐⭐ |
| 可复制性 | ⭐⭐⭐⭐⭐ |

**普通人可抄指数**：⭐⭐⭐⭐⭐

---

*📅 报告生成时间：[日期] | 🤖 由 video-content-analyzer-free 自动生成*
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
