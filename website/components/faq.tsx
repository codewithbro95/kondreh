import { Plus } from 'lucide-react'

const faqs = [
  {
    q: 'Is it really free?',
    a: 'Yes. Kondreh is free with no account. If it helps, you can buy me a coffee or donate — totally optional.',
  },
  {
    q: 'Does it record me?',
    a: 'No. It shows a live preview only. Nothing is recorded, saved, or uploaded.',
  },
  {
    q: 'Which cameras work?',
    a: 'Built-in, external webcams, and Continuity Camera. Switch between them in the preview.',
  },
  {
    q: 'Does it need internet?',
    a: 'No. Kondreh runs fully on your Mac, offline.',
  },
  {
    q: 'Which macOS versions?',
    a: 'Recent versions of macOS. [Confirm minimum macOS version before launch.]',
  },
]

export function FAQ() {
  return (
    <section id="faq" className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-3xl px-5 py-20 sm:px-8 lg:py-28">
        <h2 className="text-balance text-3xl font-bold tracking-tight text-neutral-900 sm:text-4xl">
          Questions.
        </h2>

        <div className="mt-10 divide-y divide-neutral-200 border-y border-neutral-200">
          {faqs.map((faq) => (
            <details key={faq.q} className="group py-2">
              <summary className="flex cursor-pointer list-none items-center justify-between gap-4 py-4 text-left text-lg font-medium text-neutral-900 [&::-webkit-details-marker]:hidden focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900">
                {faq.q}
                <Plus
                  className="size-5 shrink-0 text-neutral-400 transition-transform duration-200 group-open:rotate-45"
                  aria-hidden="true"
                />
              </summary>
              <p className="pb-5 pr-9 text-pretty leading-relaxed text-neutral-600">
                {faq.a}
              </p>
            </details>
          ))}
        </div>
      </div>
    </section>
  )
}
