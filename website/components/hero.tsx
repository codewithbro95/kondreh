import { ProductPreview } from './product-preview'
import { KONDREH_DOWNLOAD_PATH, KONDREH_TIP_MAILTO } from '@/lib/download'

const heroDetails = ['macOS', 'Free', 'Works offline', 'No account']

export function Hero() {
  return (
    <section
      id="top"
      className="mx-auto max-w-6xl px-5 pb-16 pt-14 sm:px-8 sm:pt-20 lg:pb-24"
    >
      <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
        <div className="max-w-xl">
          <p className="text-sm font-medium text-neutral-500">
            Mac menu bar camera preview
          </p>
          <h1 className="mt-4 text-balance text-4xl font-bold leading-[1.05] tracking-tight text-neutral-900 sm:text-5xl lg:text-6xl">
              A quick camera check before every meeting.
          </h1>
          <p className="mt-6 text-pretty text-lg leading-relaxed text-neutral-600">
            Fix your lighting and
            framing before you join the call. Try it right here.
          </p>

          <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
            <a
              href={KONDREH_DOWNLOAD_PATH}
              download
              className="inline-flex items-center justify-center rounded-lg bg-neutral-900 px-6 py-3 text-base font-medium text-white transition-colors hover:bg-neutral-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900"
            >
              Download beta 0.1
            </a>
            <a
              href={KONDREH_TIP_MAILTO}
              className="inline-flex items-center justify-center rounded-lg border border-neutral-300 bg-white px-6 py-3 text-base font-medium text-neutral-900 transition-colors hover:bg-neutral-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900"
            >
              Buy me a coffee
            </a>
          </div>

          <ul className="mt-8 flex flex-wrap gap-x-6 gap-y-2">
            {heroDetails.map((detail) => (
              <li
                key={detail}
                className="flex items-center gap-2 text-sm text-neutral-600"
              >
                <span
                  aria-hidden="true"
                  className="size-1.5 rounded-full bg-neutral-400"
                />
                {detail}
              </li>
            ))}
          </ul>
        </div>

        <div className="lg:pl-6">
          <ProductPreview />
        </div>
      </div>
    </section>
  )
}
