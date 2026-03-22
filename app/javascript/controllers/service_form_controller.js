import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "form"]

  toggle() {
    this.triggerTarget.classList.toggle("hidden")
    this.formTarget.classList.toggle("hidden")
  }
}
