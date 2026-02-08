import yt_dlp
import tempfile
import os
from saf_writer import open_output_stream

def download(url, folder_uri, fmt, context):
    with tempfile.TemporaryDirectory() as tmp:
        out = os.path.join(tmp, "%(title)s.%(ext)s")

        if fmt in ["mp3", "flac", "wav"]:
            opts = {
                "format": "bestaudio",
                "outtmpl": out,
                "postprocessors": [{
                    "key": "FFmpegExtractAudio",
                    "preferredcodec": fmt,
                }],
                "addmetadata": True,
            }
        else:
            opts = {
                "format": "bestvideo+bestaudio",
                "merge_output_format": fmt,
                "outtmpl": out,
                "addmetadata": True,
            }

        with yt_dlp.YoutubeDL(opts) as ydl:
            ydl.download([url])

        for file in os.listdir(tmp):
            path = os.path.join(tmp, file)
            with open(path, "rb") as f:
                stream = open_output_stream(context, folder_uri, file)
                stream.write(f.read())
                stream.close()
