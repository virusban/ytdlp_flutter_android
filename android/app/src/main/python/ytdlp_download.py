import yt_dlp
import os

def download(url, path, fmt):
    os.makedirs(path, exist_ok=True)

    if fmt in ["mp3", "flac", "wav"]:
        opts = {
            "format": "bestaudio/best",
            "outtmpl": f"{path}/%(title)s.%(ext)s",
            "postprocessors": [{
                "key": "FFmpegExtractAudio",
                "preferredcodec": fmt,
            }],
            "addmetadata": True,
        }
    else:
        opts = {
            "format": "bestvideo+bestaudio/best",
            "merge_output_format": fmt,
            "outtmpl": f"{path}/%(title)s.%(ext)s",
            "addmetadata": True,
        }

    with yt_dlp.YoutubeDL(opts) as ydl:
        ydl.download([url])
