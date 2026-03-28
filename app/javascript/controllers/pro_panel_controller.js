import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  
  static values = {
    profileId: Number
  }

  get urls() {
    return {
      services: "/pros/services?inline=true",
      availability: "/pros/availabilities?inline=true",
      blocked: "/pros/blocked_dates?inline=true",
      portfolio: "/pros/portfolio_photos?inline=true",
      profile: `/pros/${this.profileIdValue}/edit?inline=true`,
      subscription: "/pros/subscription?inline=true"
    }
  }

  select(event) {
    const section = event.params.section
    const url = this.urls[section]
    
    if (url && this.hasFrameTarget) {
      this.frameTarget.src = url
      this.updateActiveNav(event.currentTarget, section)
    }
  }

  updateActiveNav(activeBtn, section) {
    // Remove active state from all buttons
    this.element.querySelectorAll('.pro-nav-btn').forEach(btn => {
      btn.style.backgroundColor = 'transparent'
    })
    
    // Add active state to clicked button
    activeBtn.style.backgroundColor = 'rgba(139, 111, 71, 0.03)'
    
    // Add subtle indicator to icon container
    const iconContainer = activeBtn.querySelector('div')
    if (iconContainer) {
      iconContainer.style.backgroundColor = 'rgba(139, 111, 71, 0.15)'
    }
  }
}
