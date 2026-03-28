import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radio", "dateRange", "timeSlot"]

  connect() {
    this.toggle()
  }

  toggle() {
    const selected = this.element.querySelector('input[name="blocked_date[block_type]"]:checked')?.value

    if (this.hasDateRangeTarget) {
      this.dateRangeTarget.classList.toggle("hidden", selected !== "date_range")
    }
    if (this.hasTimeSlotTarget) {
      this.timeSlotTarget.classList.toggle("hidden", selected !== "time_slot")
    }
  }
}
