#!/bin/bash

# 视频下载和转写脚本
# 用法: ./download-transcribe.sh <视频URL> [输出目录]

URL="$1"
OUTPUT_DIR="${2:-./downloads}"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 获取视频信息
echo "📥 正在获取视频信息..."
yt-dlp --dump-json "$URL" > "$OUTPUT_DIR/video_info.json"

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
    echo ""
    echo "📝 下一步: 使用 Whisper API 转写音频"
    echo "   路径: $AUDIO_FILE"
else
    echo "❌ 音频提取失败"
    exit 1
fi
