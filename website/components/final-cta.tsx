import { KONDREH_DOWNLOAD_PATH } from '@/lib/download'

export function FinalCTA() {
  return (
    <section className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-3xl px-5 py-24 text-center sm:px-8 lg:py-32">
        <h2 className="text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
          Look right before they say hello.
        </h2>

        <div className="mt-8">
          <a
            href={KONDREH_DOWNLOAD_PATH}
            download
            className="inline-flex items-center justify-center rounded-lg bg-neutral-900 px-7 py-3.5 text-base font-medium text-white transition-colors hover:bg-neutral-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900"
          >
            Download beta 0.1
          </a>
        </div>
      </div>
    </section>
  )
}
