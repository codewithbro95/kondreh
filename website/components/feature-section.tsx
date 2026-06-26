import type { ReactNode } from 'react'
import { cn } from '@/lib/utils'

type FeatureSectionProps = {
  eyebrow: string
  title: string
  description: string
  points: string[]
  visual: ReactNode
  reversed?: boolean
}

export function FeatureSection({
  eyebrow,
  title,
  description,
  points,
  visual,
  reversed = false,
}: FeatureSectionProps) {
  return (
    <div className="grid items-center gap-10 py-14 lg:grid-cols-2 lg:gap-16 lg:py-20">
      <div className={cn('max-w-xl', reversed && 'lg:order-2 lg:justify-self-end')}>
        <p className="text-sm font-medium text-neutral-500">{eyebrow}</p>
        <h3 className="mt-3 text-balance text-2xl font-bold tracking-tight text-neutral-900 sm:text-3xl">
          {title}
        </h3>
        <p className="mt-4 text-pretty text-lg leading-relaxed text-neutral-600">
          {description}
        </p>
        <ul className="mt-6 space-y-3">
          {points.map((point) => (
            <li key={point} className="flex gap-3 text-base text-neutral-700">
              <span
                aria-hidden="true"
                className="mt-2.5 size-1.5 shrink-0 rounded-full bg-neutral-900"
              />
              <span className="leading-relaxed">{point}</span>
            </li>
          ))}
        </ul>
      </div>

      <div className={cn(reversed && 'lg:order-1')}>{visual}</div>
    </div>
  )
}
