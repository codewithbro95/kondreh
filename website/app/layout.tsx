import { Analytics } from '@vercel/analytics/next'
import type { Metadata, Viewport } from 'next'
import { Geist, Geist_Mono } from 'next/font/google'
import './globals.css'

const geistSans = Geist({ variable: '--font-geist-sans', subsets: ['latin'] })
const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
})

const siteUrl = 'https://kondreh.app'

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: 'Kondreh — Preview your camera before every call',
  description:
    'Kondreh is a free macOS menu bar app that lets you check your lighting, framing, and background before you join a video call. Works offline. No account required.',
  applicationName: 'Kondreh',
  keywords: [
    'macOS camera preview',
    'menu bar app',
    'webcam check',
    'video call preview',
    'camera mirror',
    'Continuity Camera',
  ],
  alternates: {
    canonical: siteUrl,
  },
  openGraph: {
    type: 'website',
    url: siteUrl,
    title: 'Kondreh — Preview your camera before every call',
    description:
      'A free, private camera preview for your Mac menu bar. Check lighting, framing, and background before you join.',
    siteName: 'Kondreh',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Kondreh camera preview window on macOS',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Kondreh — Preview your camera before every call',
    description:
      'A free, private camera preview for your Mac menu bar. Works offline.',
    images: ['/og-image.png'],
  },
  generator: 'v0.app',
  icons: {
    icon: [
      {
        url: '/icon-light-32x32.png',
        media: '(prefers-color-scheme: light)',
      },
      {
        url: '/icon-dark-32x32.png',
        media: '(prefers-color-scheme: dark)',
      },
      {
        url: '/icon.svg',
        type: 'image/svg+xml',
      },
    ],
    apple: '/apple-icon.png',
  },
}

export const viewport: Viewport = {
  colorScheme: 'light',
  themeColor: '#ffffff',
}

const structuredData = {
  '@context': 'https://schema.org',
  '@type': 'SoftwareApplication',
  name: 'Kondreh',
  applicationCategory: 'UtilitiesApplication',
  operatingSystem: 'macOS',
  description:
    'A free macOS menu bar app for previewing your camera before joining a video call. Check lighting, framing, and background in a quick, private window.',
  url: siteUrl,
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'USD',
    availability: 'https://schema.org/InStock',
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html
      lang="en"
      className={`light ${geistSans.variable} ${geistMono.variable}`}
    >
      <body className="bg-background font-sans antialiased">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
        />
        {children}
        {process.env.NODE_ENV === 'production' && <Analytics />}
      </body>
    </html>
  )
}
