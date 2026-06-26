import { Coffee, Download, Heart } from 'lucide-react'

const support = [
  {
    icon: Coffee,
    label: 'Buy me a coffee',
    note: '$5 — a small thanks',
    href: '#', // [replace with your Buy Me a Coffee / Ko-fi link]
  },
  {
    icon: Heart,
    label: 'Donate any amount',
    note: "Pay what it's worth to you",
    href: '#', // [replace with your donation link]
  },
]

export function Pricing() {
  return (
    <section id="download" className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-6xl px-5 py-20 sm:px-8 lg:py-28">
        <div className="mx-auto max-w-xl text-center">
          <h2 className="text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
            Free. Forever.
          </h2>
          <p className="mt-4 text-pretty text-lg leading-relaxed text-neutral-600">
            No price, no account, no catch. If it helps, you can support it.
          </p>
        </div>

        <div className="mx-auto mt-12 max-w-md rounded-2xl border border-neutral-200 bg-white p-8 shadow-[0_24px_60px_-30px_rgba(0,0,0,0.2)]">
          <div className="flex items-baseline gap-2">
            <span className="text-5xl font-bold tracking-tight text-neutral-900">
              $0
            </span>
            <span className="text-base text-neutral-500">always</span>
          </div>

          <a
            href="#" // [replace with your macOS download link]
            className="mt-6 inline-flex w-full items-center justify-center gap-2 rounded-lg bg-neutral-900 px-6 py-3 text-base font-medium text-white transition-colors hover:bg-neutral-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900"
          >
            <Download className="size-4" aria-hidden="true" />
            Download for macOS
          </a>

          <div id="support" className="mt-8 border-t border-neutral-200 pt-6">
            <p className="text-sm font-medium text-neutral-900">
              Like it? Support the work.
            </p>
            <div className="mt-4 grid gap-3">
              {support.map((item) => (
                <a
                  key={item.label}
                  href={item.href}
                  className="flex items-center gap-3 rounded-lg border border-neutral-200 bg-white p-3 transition-colors hover:bg-neutral-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900"
                >
                  <span className="flex size-9 shrink-0 items-center justify-center rounded-md bg-neutral-900 text-white">
                    <item.icon className="size-4" aria-hidden="true" />
                  </span>
                  <span>
                    <span className="block text-sm font-medium text-neutral-900">
                      {item.label}
                    </span>
                    <span className="block text-xs text-neutral-500">
                      {item.note}
                    </span>
                  </span>
                </a>
              ))}
            </div>
            <p className="mt-4 text-center text-xs text-neutral-400">
              Entirely optional. The app is always free.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
