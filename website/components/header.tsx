'use client'

import { useState } from 'react'
import { Menu, X } from 'lucide-react'
import { KONDREH_DOWNLOAD_PATH } from '@/lib/download'

const navLinks = [
  { label: 'Features', href: '#features' },
  { label: 'How it works', href: '#how-it-works' },
  { label: 'Support', href: '#support' },
  { label: 'FAQ', href: '#faq' },
]

export function Header() {
  const [open, setOpen] = useState(false)

  return (
    <header className="sticky top-0 z-50 border-b border-neutral-200 bg-white/85 backdrop-blur supports-[backdrop-filter]:bg-white/70">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8">
        <a
          href="#top"
          className="rounded-sm text-lg font-semibold tracking-tight text-neutral-900 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-neutral-900"
        >
          Kondreh
        </a>

        <nav aria-label="Primary" className="hidden md:block">
          <ul className="flex items-center gap-8">
            {navLinks.map((link) => (
              <li key={link.href}>
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

        <div className="flex items-center gap-2">
          <a
            href={KONDREH_DOWNLOAD_PATH}
            download
            className="hidden rounded-lg bg-neutral-900 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-neutral-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900 sm:inline-flex"
          >
            Download
          </a>

          <button
            type="button"
            onClick={() => setOpen((v) => !v)}
            aria-expanded={open}
            aria-controls="mobile-menu"
            aria-label={open ? 'Close menu' : 'Open menu'}
            className="inline-flex size-10 items-center justify-center rounded-lg border border-neutral-200 text-neutral-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900 md:hidden"
          >
            {open ? <X className="size-5" /> : <Menu className="size-5" />}
          </button>
        </div>
      </div>

      {open && (
        <nav
          id="mobile-menu"
          aria-label="Mobile"
          className="border-t border-neutral-200 bg-white md:hidden"
        >
          <ul className="mx-auto flex max-w-6xl flex-col px-5 py-2 sm:px-8">
            {navLinks.map((link) => (
              <li key={link.href}>
                <a
                  href={link.href}
                  onClick={() => setOpen(false)}
                  className="block rounded-md px-1 py-3 text-base text-neutral-700 hover:text-neutral-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900"
                >
                  {link.label}
                </a>
              </li>
            ))}
            <li className="py-2">
              <a
                href={KONDREH_DOWNLOAD_PATH}
                download
                onClick={() => setOpen(false)}
                className="inline-flex w-full items-center justify-center rounded-lg bg-neutral-900 px-4 py-3 text-base font-medium text-white hover:bg-neutral-700"
              >
                Download beta 0.1
              </a>
            </li>
          </ul>
        </nav>
      )}
    </header>
  )
}
