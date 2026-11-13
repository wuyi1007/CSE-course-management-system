import { Controller } from "@hotwired/stimulus"

// Base controller with common functionality
export default class extends Controller {
  // Utility methods available to all controllers
  showLoading() {
    this.element.classList.add('loading')
  }

  hideLoading() {
    this.element.classList.remove('loading')
  }

  showToast(message, type = 'info') {
    // Create toast notification
    const toast = document.createElement('div')
    toast.className = `alert alert-${type} flash-message`
    toast.innerHTML = `
      <div class="flash-content">
        <span class="flash-icon">${type === 'success' ? '✓' : type === 'error' ? '✗' : 'ℹ'}</span>
        <span>${message}</span>
      </div>
    `
    
    // Insert at top of body
    document.body.insertBefore(toast, document.body.firstChild)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      toast.remove()
    }, 5000)
  }

  // Debounce utility for search/filter inputs
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }

  // Format date for display
  formatDate(date) {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  // Handle form validation
  validateForm(form) {
    const inputs = form.querySelectorAll('input[required], select[required], textarea[required]')
    let isValid = true

    inputs.forEach(input => {
      if (!input.value.trim()) {
        input.classList.add('border-red-500')
        isValid = false
      } else {
        input.classList.remove('border-red-500')
      }
    })

    return isValid
  }
}
