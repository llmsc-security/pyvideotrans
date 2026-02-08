#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
tutorial_poc.py - PyVideoTrans Tutorial Proof of Concept

This script demonstrates how to use pyVideoTrans through Docker for various
video translation tasks. It serves as a quick start guide for users.

Usage in Docker:
    docker run -v $(pwd):/app pyvideotrans:latest python tutorial_poc.py
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path


def print_section(title):
    """Print a formatted section header."""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70 + "\n")


def check_ffmpeg():
    """Check if FFmpeg is installed."""
    print_section("Checking FFmpeg Installation")
    try:
        result = subprocess.run(
            ["ffmpeg", "-version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            version_line = [l for l in result.stdout.split('\n') if 'version' in l.lower()][0]
            print(f"✓ FFmpeg is installed: {version_line.strip()}")
            return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("✗ FFmpeg not found. Please install FFmpeg:")
        print("  - Ubuntu/Debian: sudo apt-get install ffmpeg")
        print("  - macOS: brew install ffmpeg")
        print("  - Windows: Download from https://ffmpeg.org/download.html")
    return False


def demo_cli_mode():
    """Demo CLI mode usage."""
    print_section("Demo: CLI Mode - Speech to Text (STT)")

    cli_code = '''
# Convert audio/video to subtitles
python cli.py --task stt --name "your_video.mp4" --model_name large-v3

# Options for different models:
# - faster-whisper (local): small, base, medium, large
# - openai-whisper: base, small, medium, large
# - Alibaba Qwen: qwen, qwen2
# - Volcano: spark, volc

# Video translation (complete workflow)
python cli.py --task vtv \\
    --name "your_video.mp4" \\
    --source_language_code zh \\
    --target_language_code en \\
    --model_name large-v3
'''
    print("Example CLI commands:")
    print(cli_code)


def demo_python_api():
    """Demo Python API usage."""
    print_section("Demo: Python API - Programmatic Translation")

    api_code = '''
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from videotrans.configure import config
from videotrans.task.trans_create import TransCreate

# Configure language
config.target_language = "en"
config.source_language = "zh"

# Create translation task
config.cache_folder = "./models"

# For batch processing
video_files = ["video1.mp4", "video2.mp4"]
for video_path in video_files:
    if os.path.exists(video_path):
        try:
            task = TransCreate(video_path)
            task.start()
            print(f"Completed: {video_path}")
        except Exception as e:
            print(f"Error processing {video_path}: {e}")
'''

    print("Example Python API code:")
    print(api_code)


def demo_docker_usage():
    """Demo Docker usage."""
    print_section("Demo: Docker Usage")

    docker_commands = '''
# Build the Docker image
docker build -t pyvideotrans:latest .

# Start container with volume mounts
docker run -d \\
    --name pyvideotrans \\
    -p 11160:8501 \\
    -v $(pwd)/videos:/app/videos:rw \\
    -v $(pwd)/output:/app/output:rw \\
    -v $(pwd)/models:/app/models:rw \\
    pyvideotrans:latest

# Run CLI inside container
docker exec pyvideotrans python cli.py \\
    --task stt --name "/app/videos/input.mp4"

# View logs
docker logs -f pyvideotrans

# Stop container
docker stop pyvideotrans
'''

    print("Docker commands:")
    print(docker_commands)


def demo_workflow():
    """Show the complete translation workflow."""
    print_section("Complete Translation Workflow")

    workflow = '''
1. PREPARATION
   └── Place video/audio files in ./videos/
   └── Ensure FFmpeg is installed

2. AUDIO EXTRACTION (if needed)
   └── ffmpeg -i input.mp4 -vn -acodec pcm_s16le -ar 16000 -ac 1 audio.wav

3. SPEECH RECOGNITION (STT)
   └── python cli.py --task stt --name "audio.wav" --model_name large-v3
   └── Output: output/zh.srt

4. SUBTITLE TRANSLATION (STS)
   └── python cli.py --task sts --name "output/zh.srt" --target_language_code en
   └── Output: output/en.srt

5. TEXT TO SPEECH (TTS)
   └── python cli.py --task tts --name "output/en.srt"
   └── Output: output/audio_en.wav

6. VIDEO SYNTHESIS
   └── Combine original video with new audio and subtitles
'''

    print(workflow)


def demo_supported_languages():
    """Show supported languages."""
    print_section("Supported Target Languages")

    languages = '''
- zh (Chinese)
- en (English)
- fr (French)
- de (German)
- ja (Japanese)
- ko (Korean)
- ru (Russian)
- es (Spanish)
- it (Italian)
- nl (Dutch)
- pl (Polish)
- pt (Portuguese)
- tr (Turkish)
- vi (Vietnamese)
- th (Thai)
- id (Indonesian)
- ms (Malay)
- hi (Hindi)
'''

    print(languages)


def demo_models():
    """Show available models."""
    print_section("Available Models")

    models = '''
ASR (Speech Recognition):
  - faster-whisper (local) - Recommended, fast and accurate
  - openai-whisper - Official Whisper models
  - Alibaba Qwen3-ASR - Excellent for Chinese
  - Volcano - ByteDance speech recognition

LLM (Translation):
  - DeepSeek - Cost-effective, good quality
  - ChatGPT - GPT-3.5, GPT-4
  - Claude - Anthropic models
  - Gemini - Google models
  - Ollama - Fully local

TTS (Speech Synthesis):
  - Edge-TTS - Free Microsoft voices
  - Minimax - High quality commercial
  - ChatTTS - Open source
  - CosyVoice - Voice cloning support
  - F5-TTS - Voice cloning
'''

    print(models)


def demo_storage():
    """Show storage requirements."""
    print_section("Storage Requirements")

    storage = '''
Models Storage:
  - Whisper base: ~140MB
  - Whisper small: ~450MB
  - Whisper medium: ~1.4GB
  - Whisper large: ~3GB

Total Recommended:
  - Minimum: 10GB
  - Recommended: 50GB+
  - For multiple models: 100GB+
'''

    print(storage)


def main():
    """Main entry point."""
    print("\n" + "/pyVideoTrans Tutorial POC".center(70, "="))
    print("  A Powerful Video Translation Tool".center(70))
    print("=" * 70)

    # Check FFmpeg
    ffmpeg_ok = check_ffmpeg()

    # Run demos
    demo_cli_mode()
    demo_python_api()
    demo_docker_usage()
    demo_workflow()
    demo_supported_languages()
    demo_models()
    demo_storage()

    # Summary
    print_section("Quick Start Summary")

    summary = '''
1. INSTALLATION
   pip install -r requirements.txt
   or use Docker: docker build -t pyvideotrans .

2. FIRST RUN
   python sp.py  # GUI mode
   or
   python cli.py --task stt --name "your_file.mp4"

3. DOCKER DEPLOYMENT
   ./invoke.sh start

For more information, visit: https://pyvideotrans.com
'''

    print(summary)

    if not ffmpeg_ok:
        print("\n" + "!" * 70)
        print("  WARNING: FFmpeg is not installed. Please install it first.")
        print("!" * 70 + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
