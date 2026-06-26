'use client'

import { useCallback, useEffect, useId, useRef, useState } from 'react'
import { Camera, FlipHorizontal2, Pin, VideoOff } from 'lucide-react'
import { cn } from '@/lib/utils'

type Ratio = '16:9' | '4:3' | '1:1'
type Status = 'idle' | 'loading' | 'on' | 'denied' | 'error'

type ProductPreviewProps = {
  className?: string
  startLabel?: string
  compact?: boolean
}

const ratios: { label: Ratio; value: string }[] = [
  { label: '16:9', value: '16 / 9' },
  { label: '4:3', value: '4 / 3' },
  { label: '1:1', value: '1 / 1' },
]

/**
 * A real, working camera preview that mirrors the Kondreh app experience
 * directly in the browser. Picks a camera, flips the view, and changes the
 * aspect ratio — all live. Everything stays on-device; nothing is recorded.
 */
export function ProductPreview({
  className,
  startLabel = 'Start camera',
  compact = false,
}: ProductPreviewProps) {
  const cameraSelectId = useId()
  const videoRef = useRef<HTMLVideoElement>(null)
  const streamRef = useRef<MediaStream | null>(null)

  const [status, setStatus] = useState<Status>('idle')
  const [devices, setDevices] = useState<MediaDeviceInfo[]>([])
  const [deviceId, setDeviceId] = useState<string>('')
  const [mirror, setMirror] = useState(true)
  const [ratio, setRatio] = useState<Ratio>('16:9')
  const [onTop, setOnTop] = useState(false)

  const stop = useCallback(() => {
    streamRef.current?.getTracks().forEach((t) => t.stop())
    streamRef.current = null
  }, [])

  const start = useCallback(
    async (id?: string) => {
      if (typeof navigator === 'undefined' || !navigator.mediaDevices) {
        setStatus('error')
        return
      }
      setStatus('loading')
      stop()
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: id ? { deviceId: { exact: id } } : true,
          audio: false,
        })
        streamRef.current = stream
        if (videoRef.current) {
          videoRef.current.srcObject = stream
          await videoRef.current.play().catch(() => {})
        }
        const list = await navigator.mediaDevices.enumerateDevices().catch(() => [])
        const cams = list.filter((d) => d.kind === 'videoinput')
        setDevices(cams)
        const active = stream.getVideoTracks()[0]?.getSettings().deviceId
        setDeviceId(id ?? active ?? cams[0]?.deviceId ?? '')
        setStatus('on')
      } catch (err) {
        const name = (err as DOMException)?.name
        setStatus(name === 'NotAllowedError' ? 'denied' : 'error')
      }
    },
    [stop],
  )

  useEffect(() => () => stop(), [stop])

  function handleDeviceChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const id = e.target.value
    setDeviceId(id)
    start(id)
  }

  const isOn = status === 'on'

  return (
    <figure
      className={cn(
        'w-full overflow-hidden rounded-xl border bg-white transition-all',
        onTop
          ? 'fixed bottom-4 right-4 z-[80] max-h-[calc(100vh-2rem)] w-[min(420px,calc(100vw-2rem))] border-neutral-900 shadow-[0_24px_70px_-20px_rgba(0,0,0,0.4)] sm:bottom-6 sm:right-6'
          : 'border-neutral-200 shadow-[0_24px_60px_-24px_rgba(0,0,0,0.25)]',
        className,
      )}
      aria-label="Live Kondreh camera preview"
    >
      {/* Title bar */}
      <div className="flex items-center gap-2 border-b border-neutral-200 bg-neutral-50 px-4 py-2.5">
        <div className="flex items-center gap-1.5" aria-hidden="true">
          <span className="size-3 rounded-full border border-neutral-300 bg-neutral-200" />
          <span className="size-3 rounded-full border border-neutral-300 bg-neutral-200" />
          <span className="size-3 rounded-full border border-neutral-300 bg-neutral-200" />
        </div>
        <p className="flex-1 text-center text-[13px] font-medium text-neutral-500">
          Kondreh
        </p>
        <button
          type="button"
          onClick={() => setOnTop((v) => !v)}
          aria-pressed={onTop}
          aria-label={onTop ? 'Unpin preview' : 'Pin preview'}
          className={cn(
            'inline-flex items-center gap-1 rounded-md border px-2 py-1 text-[11px] font-medium transition-colors',
            onTop
              ? 'border-neutral-900 bg-neutral-900 text-white'
              : 'border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-50',
          )}
        >
          <Pin className="size-3" />
          {onTop ? 'Pinned' : 'Pin'}
        </button>
      </div>

      {/* Camera area */}
      <div
        className="relative bg-neutral-900 transition-[aspect-ratio] duration-300"
        style={{ aspectRatio: ratios.find((r) => r.label === ratio)?.value }}
      >
        <video
          ref={videoRef}
          autoPlay
          playsInline
          muted
          onLoadedMetadata={() => videoRef.current?.play().catch(() => {})}
          className={cn(
            'size-full object-cover transition-opacity',
            isOn ? 'opacity-100' : 'opacity-0',
            mirror && '-scale-x-100',
          )}
        />

        {!isOn && (
          <div className="absolute inset-0 flex flex-col items-center justify-center gap-4 px-6 text-center">
            {status === 'denied' || status === 'error' ? (
              <>
                <VideoOff className="size-8 text-neutral-500" aria-hidden="true" />
                <p className="max-w-xs text-sm text-neutral-300">
                  {status === 'denied'
                    ? 'Camera access was blocked. Allow it in your browser, then try again.'
                    : 'No camera available on this device.'}
                </p>
                <button
                  type="button"
                  onClick={() => start()}
                  className="rounded-lg bg-white px-4 py-2 text-sm font-medium text-neutral-900 hover:bg-neutral-200"
                >
                  Try again
                </button>
              </>
            ) : (
              <>
                <div className="flex size-14 items-center justify-center rounded-full bg-white/10">
                  <Camera className="size-7 text-white" aria-hidden="true" />
                </div>
                <p className="text-sm text-neutral-300">
                  Try the real preview, right here.
                </p>
                <button
                  type="button"
                  onClick={() => start()}
                  disabled={status === 'loading'}
                  className="rounded-lg bg-white px-5 py-2.5 text-sm font-medium text-neutral-900 transition-colors hover:bg-neutral-200 disabled:opacity-60"
                >
                  {status === 'loading' ? 'Starting...' : startLabel}
                </button>
              </>
            )}
          </div>
        )}

        {isOn && (
          <div className="absolute left-3 top-3 inline-flex items-center gap-1.5 rounded-full border border-white/20 bg-black/40 px-2 py-1 text-[11px] font-medium text-white backdrop-blur">
            <span className="size-1.5 animate-pulse rounded-full bg-white" />
            Live
          </div>
        )}
      </div>

      {/* Controls */}
      <div
        className={cn(
          'flex flex-wrap items-center gap-2 border-t border-neutral-200 bg-white px-3 py-3',
          compact && 'px-2.5 py-2.5',
        )}
      >
        <label className="sr-only" htmlFor={cameraSelectId}>
          Choose camera
        </label>
        {devices.length === 0 ? (
          <button
            id={cameraSelectId}
            type="button"
            onClick={() => start()}
            disabled={status === 'loading'}
            className="flex-1 truncate rounded-md border border-neutral-200 bg-white px-2.5 py-1.5 text-left text-[12px] font-medium text-neutral-500 transition-colors hover:bg-neutral-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900 disabled:opacity-60"
          >
            {status === 'loading' ? 'Starting...' : 'Start camera to choose'}
          </button>
        ) : (
          <select
            id={cameraSelectId}
            value={deviceId}
            onChange={handleDeviceChange}
            disabled={!isOn}
            className="flex-1 truncate rounded-md border border-neutral-200 bg-white px-2.5 py-1.5 text-[12px] font-medium text-neutral-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900 disabled:text-neutral-400"
          >
            {devices.map((d, i) => (
              <option key={d.deviceId} value={d.deviceId}>
                {d.label || `Camera ${i + 1}`}
              </option>
            ))}
          </select>
        )}

        <button
          type="button"
          onClick={() => setMirror((v) => !v)}
          aria-pressed={mirror}
          className={cn(
            'inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1.5 text-[12px] font-medium transition-colors',
            mirror
              ? 'border-neutral-900 bg-neutral-900 text-white'
              : 'border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-50',
          )}
        >
          <FlipHorizontal2 className="size-3.5" />
          Mirror
        </button>

        <div className="inline-flex items-center gap-0.5 rounded-md border border-neutral-200 bg-white p-0.5 text-[11px] font-medium text-neutral-600">
          {ratios.map((r) => (
            <button
              key={r.label}
              type="button"
              onClick={() => setRatio(r.label)}
              aria-pressed={ratio === r.label}
              className={cn(
                'rounded px-1.5 py-1 transition-colors',
                ratio === r.label
                  ? 'bg-neutral-900 text-white'
                  : 'hover:bg-neutral-100',
              )}
            >
              {r.label}
            </button>
          ))}
        </div>
      </div>
    </figure>
  )
}
