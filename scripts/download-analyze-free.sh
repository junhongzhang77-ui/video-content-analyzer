#!/bin/bash

# 视频下载+转写+弹幕获取脚本（免费版）
# 依赖: yt-dlp, ffmpeg, coqui-stt
# 用法: ./download-analyze-free.sh <视频URL> [输出目录]

URL="$1"
OUTPUT_DIR="${2:-./analysis}"

if [ -z "$URL" ]; then
    echo "❌ 请提供视频链接"
    echo "用法: $0 <视频URL> [输出目录]"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 获取视频信息
echo "📥 正在获取视频信息..."
yt-dlp --dump-json "$URL" > "$OUTPUT_DIR/video_info.json" 2>/dev/null

# 获取标题
TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null)
echo "📺 视频标题: $TITLE"

# 下载视频
echo "⬇️ 正在下载视频..."
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
    --output "$OUTPUT_DIR/video.%(ext)s" \
    "$URL"

# 获取下载的文件
VIDEO_FILE=$(ls -t "$OUTPUT_DIR"/video.* 2>/dev/null | head -1)

if [ -z "$VIDEO_FILE" ]; then
    echo "❌ 视频下载失败"
    exit 1
fi

echo "✅ 视频下载完成: $VIDEO_FILE"

# 提取音频
echo "🎵 正在提取音频..."
AUDIO_FILE="$OUTPUT_DIR/audio.mp3"
ffmpeg -i "$VIDEO_FILE" -vn -acodec libmp3lame -q:a 2 "$AUDIO_FILE" -y 2>/dev/null

if [ -f "$AUDIO_FILE" ]; then
    echo "✅ 音频提取完成: $AUDIO_FILE"
else
    echo "❌ 音频提取失败"
    exit 1
fi

# 下载弹幕 (B站)
echo "💬 正在下载弹幕..."
DANMU_FILE="$OUTPUT_DIR/danmu.ass"
yt-dlp --write-subs --sub-format ass --skip-download -o "$OUTPUT_DIR/danmu" "$URL" 2>/dev/null

if [ -f "$OUTPUT_DIR/danmu.ass" ]; then
    echo "✅ 弹幕下载完成: $DANMU_FILE"
    # 提取弹幕文本
    if command -v sed &> /dev/null; then
        sed -n '/^Dialogue:/p' "$OUTPUT_DIR/danmu.ass" | sed 's/.*,.*,.*,.*,.*,.*,.*,.*,.*,//' > "$OUTPUT_DIR/danmu_text.txt"
        echo "✅ 弹幕文本提取完成: $OUTPUT_DIR/danmu_text.txt"
    fi
else
    echo "⚠️ 弹幕下载失败（非B站视频或需要登录）"
fi

# Coqui 转写
echo "📝 正在转写语音 (Coqui)..."
TRANSCRIPT_FILE="$OUTPUT_DIR/transcript.txt"

# 检查 Coqui 模型是否存在
COQUI_MODEL_DIR="${COQUI_MODEL_DIR:-$HOME/.coqui}"
if [ -d "$COQUI_MODEL_DIR" ]; then
    coqui-stt --model "$COQUI_MODEL_DIR/model" --scorer "$COQUI_MODEL_DIR/scorer" "$AUDIO_FILE" > "$TRANSCRIPT_FILE" 2>/dev/null
    if [ -s "$TRANSCRIPT_FILE" ]; then
        echo "✅ 语音转写完成: $TRANSCRIPT_FILE"
    else
        echo "⚠️ Coqui 转写失败，尝试直接读取..."
        echo "提示: 请确保 Coqui 模型已下载到 $COQUI_MODEL_DIR"
    fi
else
    echo "⚠️ Coqui 模型目录不存在: $COQUI_MODEL_DIR"
    echo "请先下载 Coqui 模型"
fi

# 输出总结
echo ""
echo "========================================"
echo "✅ 分析素材准备完成！"
echo "========================================"
echo ""
echo "📁 输出目录: $OUTPUT_DIR"
echo ""
echo "📄 生成的文件:"
[ -f "$VIDEO_FILE" ] && echo "  📹 video.* - 原始视频"
[ -f "$AUDIO_FILE" ] && echo "  🎵 audio.mp3 - 提取音频"
[ -f "$OUTPUT_DIR/danmu.ass" ] && echo "  💬 danmu.ass - 弹幕(ASS)"
[ -f "$OUTPUT_DIR/danmu_text.txt" ] && echo "  💬 danmu_text.txt - 弹幕文本"
[ -f "$TRANSCRIPT_FILE" ] && echo "  📝 transcript.txt - 语音转写"
echo ""
echo "========================================"
echo "📌 下一步操作:"
echo "========================================"
echo ""
echo "1. 检查转写文件是否成功生成"
echo "2. 将 transcript.txt (文案) + danmu_text.txt (弹幕)"
echo "   发送给免费 AI (Kimi/智谱清言) 进行分析"
echo ""
echo "📋 AI 分析提示词:"
echo "----------------------------------------"
cat << 'PROMPT'
请分析以下短视频的文案和弹幕数据，输出：

1. 视频结构（时间线+内容类型）
2. 钩子设计分析（开头3秒）
3. 节奏把控分析
4. 弹幕热点总结
5. 总结与可复用点

---
语音文案:
[将 transcript.txt 内容粘贴在此]

弹幕数据:
[将 danmu_text.txt 内容粘贴在此]
PROMPT
echo ""
