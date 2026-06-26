import { Camera, ChevronDown, Command, FlipHorizontal2, Move, Pin, Video } from 'lucide-react'
import { FeatureSection } from './feature-section'

function MenuBarVisual() {
  return (
    <div className="overflow-hidden rounded-xl border border-neutral-200 bg-neutral-100 shadow-[0_24px_60px_-24px_rgba(0,0,0,0.25)]">
      {/* macOS menu bar */}
      <div className="flex items-center justify-end gap-4 border-b border-neutral-200 bg-white/80 px-4 py-2 text-[12px] text-neutral-500 backdrop-blur">
        <span>Wed 9:41</span>
        <span className="font-medium text-neutral-900">
          <Camera className="inline size-4" aria-label="Kondreh menu bar icon" />
        </span>
      </div>

      {/* Dropdown menu */}
      <div className="px-4 pb-8 pt-3">
        <div className="ml-auto w-60 overflow-hidden rounded-lg border border-neutral-200 bg-white shadow-sm">
          <div className="flex items-center justify-between bg-neutral-900 px-3 py-2 text-[13px] font-medium text-white">
            <span className="inline-flex items-center gap-2">
              <Video className="size-4" aria-hidden="true" />
              Open Preview
            </span>
            <span className="inline-flex items-center gap-0.5 text-[12px] text-neutral-300">
              <Command className="size-3" aria-hidden="true" />K
            </span>
          </div>
          <ul className="divide-y divide-neutral-100 text-[13px] text-neutral-700">
            <li className="px-3 py-2">Choose camera…</li>
            <li className="px-3 py-2">Keep window on top</li>
            <li className="px-3 py-2 text-neutral-400">Quit Kondreh</li>
          </ul>
        </div>
      </div>
    </div>
  )
}

function CameraControlsVisual() {
  return (
    <div className="overflow-hidden rounded-xl border border-neutral-200 bg-white shadow-[0_24px_60px_-24px_rgba(0,0,0,0.25)]">
      <div className="flex items-center gap-1.5 border-b border-neutral-200 bg-neutral-50 px-3 py-2">
        <span className="size-2.5 rounded-full bg-neutral-200" />
        <span className="size-2.5 rounded-full bg-neutral-200" />
        <span className="size-2.5 rounded-full bg-neutral-200" />
      </div>
      <div className="flex aspect-[4/3] items-center justify-center bg-neutral-900 text-neutral-600">
        <Camera className="size-8" aria-hidden="true" />
      </div>
      <div className="flex items-center gap-2 border-t border-neutral-200 px-3 py-3">
        <div className="inline-flex flex-1 items-center justify-between rounded-md border border-neutral-200 px-2.5 py-1.5 text-[12px] font-medium text-neutral-700">
          <span className="truncate">FaceTime HD Camera</span>
          <ChevronDown className="size-3.5 text-neutral-400" aria-hidden="true" />
        </div>
        <span className="inline-flex items-center gap-1.5 rounded-md border border-neutral-900 bg-neutral-900 px-2.5 py-1.5 text-[12px] font-medium text-white">
          <FlipHorizontal2 className="size-3.5" />
          Mirror
        </span>
      </div>
    </div>
  )
}

function WindowBehaviorVisual() {
  return (
    <div className="rounded-xl border border-neutral-200 bg-neutral-100 p-8 shadow-[0_24px_60px_-24px_rgba(0,0,0,0.25)]">
      <div className="relative">
        {/* Base window */}
        <div className="ml-auto w-3/4 overflow-hidden rounded-lg border border-neutral-200 bg-white opacity-60">
          <div className="flex items-center gap-1.5 border-b border-neutral-200 bg-neutral-50 px-3 py-2">
            <span className="size-2.5 rounded-full bg-neutral-200" />
            <span className="size-2.5 rounded-full bg-neutral-200" />
            <span className="size-2.5 rounded-full bg-neutral-200" />
          </div>
          <div className="aspect-[16/10] bg-neutral-100" />
        </div>

        {/* Floating, always-on-top preview */}
        <div className="absolute -left-0 top-6 w-3/5 overflow-hidden rounded-lg border border-neutral-300 bg-white shadow-[0_16px_40px_-16px_rgba(0,0,0,0.35)]">
          <div className="flex items-center justify-between border-b border-neutral-200 bg-neutral-50 px-3 py-2">
            <div className="flex items-center gap-1.5">
              <span className="size-2.5 rounded-full bg-neutral-200" />
              <span className="size-2.5 rounded-full bg-neutral-200" />
              <span className="size-2.5 rounded-full bg-neutral-200" />
            </div>
            <span className="inline-flex items-center gap-1 rounded border border-neutral-900 bg-neutral-900 px-1.5 py-0.5 text-[10px] font-medium text-white">
              <Pin className="size-2.5" aria-hidden="true" />
              On top
            </span>
          </div>
          <div className="flex aspect-[4/3] items-center justify-center bg-neutral-100 text-neutral-300">
            <Move className="size-6" aria-hidden="true" />
          </div>
        </div>
      </div>
    </div>
  )
}

export function Features() {
  return (
    <section id="features" className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-6xl px-5 sm:px-8">
        <div className="border-b border-neutral-200 py-14 lg:py-20">
          <h2 className="max-w-2xl text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
            One job, done well.
          </h2>
        </div>

        <div className="divide-y divide-neutral-200">
          <FeatureSection
            eyebrow="Instant preview"
            title="One keystroke from the menu bar."
            description="Lives in your menu bar, out of the Dock. Open the preview when you need it, close it when you don't."
            points={[
              'Open from the menu bar icon',
              'Trigger it with a global shortcut',
              'Close instantly before you join',
            ]}
            visual={<MenuBarVisual />}
          />

          <FeatureSection
            eyebrow="Camera controls"
            title="Every camera, framed your way."
            description="Switch sources, flip the view, pick an aspect ratio. What you see is what your meeting sends."
            points={[
              'Built-in, external, and Continuity Camera',
              'Mirror the preview',
              'Change the aspect ratio',
            ]}
            visual={<CameraControlsVisual />}
            reversed
          />

          <FeatureSection
            eyebrow="Window behavior"
            title="Stays put while you get ready."
            description="Keep the preview floating above everything else, and Kondreh remembers how you like it."
            points={[
              'Always on top',
              'Resize and reposition',
              'Remembers camera, size, and placement',
            ]}
            visual={<WindowBehaviorVisual />}
          />
        </div>
      </div>
    </section>
  )
}
