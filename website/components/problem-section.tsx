const moments = [
  'Backlit by the window, you join as a silhouette.',
  'Your face is cropped at the forehead.',
  'Something embarrassing is in frame.',
  'You open Zoom just to use it as a mirror.',
]

export function ProblemSection() {
  return (
    <section className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-6xl px-5 py-20 sm:px-8 lg:py-28">
        <div className="grid gap-12 lg:grid-cols-[1fr_1.1fr] lg:gap-16">
          <div className="max-w-md">
            <h2 className="text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
              The check that happens too late.
            </h2>
            <p className="mt-6 text-pretty text-lg leading-relaxed text-neutral-600">
              You fix your framing in the first seconds of the call — the
              seconds everyone sees. Kondreh moves that check a moment earlier.
            </p>
          </div>

          <ul className="divide-y divide-neutral-200 border-y border-neutral-200">
            {moments.map((moment, index) => (
              <li key={moment} className="flex gap-5 py-5">
                <span className="font-mono text-sm tabular-nums text-neutral-400">
                  {String(index + 1).padStart(2, '0')}
                </span>
                <p className="text-pretty text-base leading-relaxed text-neutral-700">
                  {moment}
                </p>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  )
}
