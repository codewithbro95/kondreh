import { KONDREH_DOWNLOAD_PATH } from '@/lib/download'

const footerLinks = [
  { label: 'Download', href: KONDREH_DOWNLOAD_PATH },
  { label: 'Support', href: '#support' },
  { label: 'Privacy', href: '#' },
  { label: 'Contact', href: 'mailto:hello@kondreh.app' },
]

export function Footer() {
  return (
    <footer className="border-t border-neutral-200 bg-white">
      <div className="mx-auto max-w-6xl px-5 py-14 sm:px-8">
        <div className="flex flex-col gap-10 md:flex-row md:items-start md:justify-between">
          <div className="max-w-sm">
            <p className="text-lg font-semibold tracking-tight text-neutral-900">
              Kondreh
            </p>
            <p className="mt-3 text-pretty leading-relaxed text-neutral-600">
              A free macOS menu bar camera preview.
            </p>
          </div>

          <nav aria-label="Footer">
            <ul className="flex flex-col gap-3 sm:flex-row sm:gap-8">
              {footerLinks.map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    className="rounded-sm text-sm text-neutral-600 transition-colors hover:text-neutral-900 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-neutral-900"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </nav>
        </div>

        <div className="mt-12 flex flex-col gap-2 border-t border-neutral-200 pt-6 text-sm text-neutral-500 sm:flex-row sm:items-center sm:justify-between">
          <p>
            Support:{' '}
            <a
              href="mailto:support@kondreh.app"
              className="rounded-sm underline-offset-4 hover:text-neutral-900 hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-neutral-900"
            >
              support@kondreh.app
            </a>{' '}
            [placeholder]
          </p>
          <p>© {new Date().getFullYear()} Kondreh. All rights reserved.</p>
        </div>
      </div>
    </footer>
  )
}
