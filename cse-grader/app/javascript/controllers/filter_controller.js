import BaseController from "./base_controller"

// Connects to data-controller="filter"
export default class extends BaseController {
  static targets = ["form", "preview"]

  connect() {
    console.log("Filter controller connected")
    // Debounce the preview updates for better performance
    this.debouncedUpdatePreview = this.debounce(this.updatePreview.bind(this), 300)
  }

  updatePreview() {
    if (this.hasPreviewTarget) {
      const formData = new FormData(this.formTarget)
      const term = formData.get('term') || '1248'
      const campus = formData.get('campus') || 'col'
      const subject = formData.get('subject') || 'All subjects'
      
      // Update preview elements
      const termElement = this.previewTarget.querySelector('#preview-term')
      const campusElement = this.previewTarget.querySelector('#preview-campus')
      const subjectElement = this.previewTarget.querySelector('#preview-subject')
      
      if (termElement) termElement.textContent = term
      if (campusElement) {
        const campusNames = {
          'col': 'Columbus (Main Campus)',
          'lma': 'Lima',
          'mns': 'Mansfield',
          'mrn': 'Marion',
          'nwk': 'Newark',
          'wst': 'Wooster'
        }
        campusElement.textContent = campusNames[campus] || campus
      }
      if (subjectElement) {
        subjectElement.textContent = subject || 'All subjects'
      }
    }
  }

  submitForm() {
    // Validate form before submission
    if (!this.validateForm(this.formTarget)) {
      this.showToast('Please fill in all required fields', 'error')
      return
    }

    // Show loading state
    this.showLoading()
    this.showToast('Reloading course data...', 'info')

    const submitButton = this.formTarget.querySelector('input[type="submit"]')
    if (submitButton) {
      submitButton.disabled = true
      submitButton.value = "Reloading..."
      submitButton.classList.add('opacity-50', 'cursor-not-allowed')
    }

    // Show progress section
    const progressSection = document.getElementById('reload-progress')
    if (progressSection) {
      progressSection.classList.remove('hidden')
    }
  }
}
