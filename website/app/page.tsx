import { Header } from '@/components/header'
import { Hero } from '@/components/hero'
import { ProblemSection } from '@/components/problem-section'
import { Features } from '@/components/features'
import { Steps } from '@/components/steps'
import { PrivacySection } from '@/components/privacy-section'
import { Pricing } from '@/components/pricing'
import { FAQ } from '@/components/faq'
import { FinalCTA } from '@/components/final-cta'
import { Footer } from '@/components/footer'

export default function Page() {
  return (
    <div className="min-h-screen bg-white text-neutral-900">
      <Header />
      <main>
        <Hero />
        <ProblemSection />
        <Features />
        <Steps />
        <PrivacySection />
        <Pricing />
        <FAQ />
        <FinalCTA />
      </main>
      <Footer />
    </div>
  )
}
