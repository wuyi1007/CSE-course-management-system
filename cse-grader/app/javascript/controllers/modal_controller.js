import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal", "backdrop"]

  connect() {
    console.log("Modal controller connected")
  }

  open() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove('hidden')
      this.modalTarget.classList.add('flex')
      document.body.classList.add('overflow-hidden')
    }
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add('hidden')
      this.modalTarget.classList.remove('flex')
      document.body.classList.remove('overflow-hidden')
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
