const YOUTUBE_ID = /^[a-zA-Z0-9_-]{11}$/;

export function extractYouTubeVideoId(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const input = value.trim();
  if (YOUTUBE_ID.test(input)) return input;

  try {
    const url = new URL(input);
    const host = url.hostname.toLowerCase().replace(/^www\./, '');
    let candidate: string | null = null;

    if (host === 'youtu.be') {
      candidate = url.pathname.split('/').filter(Boolean)[0] ?? null;
    } else if (host === 'youtube.com' || host.endsWith('.youtube.com')) {
      candidate = url.searchParams.get('v');
      if (!candidate) {
        const parts = url.pathname.split('/').filter(Boolean);
        if (['embed', 'shorts', 'live', 'v'].includes(parts[0])) {
          candidate = parts[1] ?? null;
        }
      }
    }

    return candidate && YOUTUBE_ID.test(candidate) ? candidate : null;
  } catch {
    return null;
  }
}

export function youtubeThumbnailUrl(videoId: string): string {
  return `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`;
}

export function isYouTubeThumbnailFor(
  value: unknown,
  videoId: string | null,
): boolean {
  if (!videoId || typeof value !== 'string') return false;
  return /^https?:\/\/(?:img\.youtube\.com|i\.ytimg\.com)\//i.test(value) &&
    value.includes(`/vi/${videoId}/`);
}
