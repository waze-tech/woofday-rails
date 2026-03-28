import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    this.update()
  }

  select(event) {
    this.update()
  }

  update() {
    const checked = this.element.querySelector('input[name="review[rating]"]:checked')
    const value = checked ? parseInt(checked.value) : 0

    this.starTargets.forEach(star => {
      const starValue = parseInt(star.dataset.value)
      star.style.color = starValue <= value ? "#F59E0B" : "#E8E0D5"
    })
  }
}
