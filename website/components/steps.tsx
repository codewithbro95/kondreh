const steps = [
  {
    title: 'Install',
    description: 'Drag Kondreh to Applications. It launches into the menu bar.',
  },
  {
    title: 'Open',
    description: 'Click the icon or press your shortcut to see the preview.',
  },
  {
    title: 'Join',
    description: 'Fix your shot, close Kondreh, and start the call.',
  },
]

export function Steps() {
  return (
    <section id="how-it-works" className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-6xl px-5 py-20 sm:px-8 lg:py-28">
        <h2 className="max-w-xl text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
          Three steps, then you forget it&apos;s there.
        </h2>

        <ol className="mt-12 grid gap-px overflow-hidden rounded-xl border border-neutral-200 bg-neutral-200 sm:grid-cols-3">
          {steps.map((step, index) => (
            <li key={step.title} className="bg-white p-7">
              <span className="font-mono text-sm tabular-nums text-neutral-400">
                Step {index + 1}
              </span>
              <h3 className="mt-3 text-lg font-semibold text-neutral-900">
                {step.title}
              </h3>
              <p className="mt-2 text-pretty leading-relaxed text-neutral-600">
                {step.description}
              </p>
            </li>
          ))}
        </ol>
      </div>
    </section>
  )
}
