import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "roleSection", "accountSection", "trustSection", "roleInput", "roleLabel"]
  static values = { presetRole: String, presetPlan: String }

  connect() {
    // If role is preset (coming from pricing page), skip role selection
    if (this.presetRoleValue === "pro") {
      this.showProForm()
    }
  }

  showProForm() {
    // Set the role to pro
    this.roleInputTargets.forEach(input => {
      input.checked = input.value === "pro"
    })
    
    // Update role label with plan info
    const planText = this.presetPlanValue === "pro" ? "Pro Plan" : "Free Plan"
    this.roleLabelTarget.textContent = `Signing up as Pet Care Professional (${planText})`
    
    // Show account section, hide role section
    this.roleSectionTarget.classList.add('hidden')
    this.accountSectionTarget.classList.remove('hidden')
    this.trustSectionTarget.classList.add('hidden')
  }

  selectRole(event) {
    const role = event.currentTarget.dataset.role
    
    // If Pro selected, redirect to pricing page
    if (role === "pro") {
      window.location.href = "/pricing"
      return
    }
    
    // Update radio button
    this.roleInputTargets.forEach(input => {
      input.checked = input.value === role
    })
    
    // Update role label
    const roleText = "Pet Owner"
    this.roleLabelTarget.textContent = `Signing up as ${roleText}`
    
    // Highlight selected card
    document.querySelectorAll('.role-card').forEach(card => {
      card.style.borderColor = 'rgba(139, 111, 71, 0.15)'
      card.style.backgroundColor = 'white'
    })
    event.currentTarget.style.borderColor = '#8B6F47'
    event.currentTarget.style.backgroundColor = 'rgba(139, 111, 71, 0.05)'
    
    // Show account section, hide role section
    this.roleSectionTarget.classList.add('hidden')
    this.accountSectionTarget.classList.remove('hidden')
    this.trustSectionTarget.classList.add('hidden')
  }

  changeRole() {
    // If preset role, go back to pricing
    if (this.presetRoleValue === "pro") {
      window.location.href = "/pricing"
      return
    }
    
    // Show role section, hide account section
    this.roleSectionTarget.classList.remove('hidden')
    this.accountSectionTarget.classList.add('hidden')
    this.trustSectionTarget.classList.remove('hidden')
    
    // Reset card styles
    document.querySelectorAll('.role-card').forEach(card => {
      card.style.borderColor = 'rgba(139, 111, 71, 0.15)'
      card.style.backgroundColor = 'white'
    })
  }
}
