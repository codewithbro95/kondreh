const privacyPoints = [
  'Everything stays on your Mac',
  'No recording',
  'No uploads',
  'No microphone',
  'No account',
  'Camera stops when you close it',
]

export function PrivacySection() {
  return (
    <section id="privacy" className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-6xl px-5 py-20 sm:px-8 lg:py-28">
        <div className="grid gap-12 lg:grid-cols-[1fr_1.1fr] lg:gap-16">
          <div className="max-w-md">
            <p className="text-sm font-medium text-neutral-500">Privacy</p>
            <h2 className="mt-3 text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
              A preview, and nothing more.
            </h2>
            <p className="mt-6 text-pretty text-lg leading-relaxed text-neutral-600">
              Nothing is saved or sent. The camera light goes off the instant
              you close the window.
            </p>
          </div>

          <ul className="grid gap-px overflow-hidden rounded-xl border border-neutral-200 bg-neutral-200 sm:grid-cols-2">
            {privacyPoints.map((point) => (
              <li
                key={point}
                className="bg-white p-5 text-base leading-relaxed text-neutral-800"
              >
                {point}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  )
}
