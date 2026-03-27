import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "emailStatus", "password", "passwordStatus", "passwordConfirmation", "confirmationStatus", "submit"]
  static values = { checkEmailUrl: String }
  
  connect() {
    this.emailTimeout = null
    this.emailValid = false
    this.passwordValid = false
    this.confirmationValid = false
  }
  
  validateEmail() {
    const email = this.emailTarget.value.trim()
    
    // Clear previous timeout
    if (this.emailTimeout) clearTimeout(this.emailTimeout)
    
    // Basic format check first
    if (!email) {
      this.setStatus(this.emailStatusTarget, null)
      this.emailValid = false
      this.updateSubmit()
      return
    }
    
    if (!this.isValidEmailFormat(email)) {
      this.setStatus(this.emailStatusTarget, false, "Enter a valid email address")
      this.emailValid = false
      this.updateSubmit()
      return
    }
    
    // Show loading state
    this.setStatus(this.emailStatusTarget, "loading")
    
    // Debounce the server check
    this.emailTimeout = setTimeout(() => {
      this.checkEmailAvailability(email)
    }, 500)
  }
  
  async checkEmailAvailability(email) {
    try {
      const response = await fetch(`/api/check_email?email=${encodeURIComponent(email)}`)
      const data = await response.json()
      
      if (data.available) {
        this.setStatus(this.emailStatusTarget, true, "Email available")
        this.emailValid = true
      } else {
        this.setStatus(this.emailStatusTarget, false, "Email already taken")
        this.emailValid = false
      }
    } catch (error) {
      // On error, allow form submission (server will validate)
      this.setStatus(this.emailStatusTarget, null)
      this.emailValid = true
    }
    this.updateSubmit()
  }
  
  validatePassword() {
    const password = this.passwordTarget.value
    
    if (!password) {
      this.setStatus(this.passwordStatusTarget, null)
      this.passwordValid = false
      this.updateSubmit()
      return
    }
    
    if (password.length < 8) {
      this.setStatus(this.passwordStatusTarget, false, `${8 - password.length} more characters needed`)
      this.passwordValid = false
    } else {
      this.setStatus(this.passwordStatusTarget, true, "Password meets requirements")
      this.passwordValid = true
    }
    
    // Re-validate confirmation if it has a value
    if (this.passwordConfirmationTarget.value) {
      this.validateConfirmation()
    }
    this.updateSubmit()
  }
  
  validateConfirmation() {
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value
    
    if (!confirmation) {
      this.setStatus(this.confirmationStatusTarget, null)
      this.confirmationValid = false
      this.updateSubmit()
      return
    }
    
    if (password !== confirmation) {
      this.setStatus(this.confirmationStatusTarget, false, "Passwords don't match")
      this.confirmationValid = false
    } else {
      this.setStatus(this.confirmationStatusTarget, true, "Passwords match")
      this.confirmationValid = true
    }
    this.updateSubmit()
  }
  
  setStatus(element, status, message = "") {
    if (status === null) {
      element.innerHTML = ""
      element.className = "validation-status"
      return
    }
    
    if (status === "loading") {
      element.innerHTML = `
        <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
        </svg>
      `
      element.className = "validation-status text-gray-400"
      return
    }
    
    if (status === true) {
      element.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="#22c55e" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
        <span class="text-xs ml-1" style="color: #22c55e;">${message}</span>
      `
      element.className = "validation-status flex items-center"
    } else {
      element.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="#ef4444" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
        <span class="text-xs ml-1" style="color: #ef4444;">${message}</span>
      `
      element.className = "validation-status flex items-center"
    }
  }
  
  isValidEmailFormat(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  }
  
  updateSubmit() {
    if (this.hasSubmitTarget) {
      const allValid = this.emailValid && this.passwordValid && this.confirmationValid
      this.submitTarget.disabled = !allValid
      this.submitTarget.style.opacity = allValid ? "1" : "0.5"
      this.submitTarget.style.cursor = allValid ? "pointer" : "not-allowed"
    }
  }
}
