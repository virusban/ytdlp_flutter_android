import yt_dlp
import ffmpeg
import os

def download(url, save_path, fmt):
    ydl_opts = {
        'outtmpl': os.path.join(save_path, '%(title)s.%(ext)s'),
        'format': 'best',
        'progress_hooks': [progress_hook]
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=True)
        filepath = ydl.prepare_filename(info)

        if fmt in ['mp3', 'flac', 'wav']:
            out_file = os.path.join(save_path, f"{info['title']}.{fmt}")
            stream = ffmpeg.input(filepath)
            stream = ffmpeg.output(stream, out_file, **{'metadata': 'title='+info['title']})
            ffmpeg.run(stream)

    return f"Downloaded {info['title']} as {fmt}"

def progress_hook(d):
    if d['status'] == 'downloading':
        total_bytes = d.get('total_bytes') or d.get('total_bytes_estimate')
        downloaded = d.get('downloaded_bytes', 0)
        if total_bytes:
            percent = downloaded / total_bytes * 100
            print(f"{percent:.2f}% Downloaded", flush=True)
    elif d['status'] == 'finished':
        print("Download finished", flush=True)
