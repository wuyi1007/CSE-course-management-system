// Performance utilities for the CSE Grader application

// Lazy loading for images and components
export const lazyLoad = {
  // Lazy load images
  images: () => {
    const images = document.querySelectorAll('img[data-src]')
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target
          img.src = img.dataset.src
          img.classList.remove('lazy')
          observer.unobserve(img)
        }
      })
    })

    images.forEach(img => imageObserver.observe(img))
  },

  // Lazy load components
  components: () => {
    const components = document.querySelectorAll('[data-lazy-component]')
    const componentObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const component = entry.target
          const componentName = component.dataset.lazyComponent
          
          // Load component dynamically
          import(`../components/${componentName}.js`).then(module => {
            module.default(component)
          })
          
          observer.unobserve(component)
        }
      })
    })

    components.forEach(component => componentObserver.observe(component))
  }
}

// Debounce utility for performance
export const debounce = (func, wait, immediate = false) => {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      timeout = null
      if (!immediate) func(...args)
    }
    const callNow = immediate && !timeout
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
    if (callNow) func(...args)
  }
}

// Throttle utility for performance
export const throttle = (func, limit) => {
  let inThrottle
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args)
      inThrottle = true
      setTimeout(() => inThrottle = false, limit)
    }
  }
}

// Memory management
export const memoryManager = {
  // Clean up event listeners
  cleanup: (element) => {
    const events = element._events || []
    events.forEach(({ event, handler }) => {
      element.removeEventListener(event, handler)
    })
    element._events = []
  },

  // Track memory usage
  track: () => {
    if (performance.memory) {
      console.log('Memory usage:', {
        used: Math.round(performance.memory.usedJSHeapSize / 1048576) + ' MB',
        total: Math.round(performance.memory.totalJSHeapSize / 1048576) + ' MB',
        limit: Math.round(performance.memory.jsHeapSizeLimit / 1048576) + ' MB'
      })
    }
  }
}

// Performance monitoring
export const performanceMonitor = {
  // Measure page load time
  measureLoadTime: () => {
    window.addEventListener('load', () => {
      const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart
      console.log(`Page load time: ${loadTime}ms`)
    })
  },

  // Measure function execution time
  measureFunction: (func, name) => {
    const start = performance.now()
    const result = func()
    const end = performance.now()
    console.log(`${name} execution time: ${end - start}ms`)
    return result
  },

  // Monitor Core Web Vitals
  monitorVitals: () => {
    // Largest Contentful Paint
    new PerformanceObserver((list) => {
      const entries = list.getEntries()
      const lastEntry = entries[entries.length - 1]
      console.log('LCP:', lastEntry.startTime)
    }).observe({ entryTypes: ['largest-contentful-paint'] })

    // First Input Delay
    new PerformanceObserver((list) => {
      const entries = list.getEntries()
      entries.forEach(entry => {
        console.log('FID:', entry.processingStart - entry.startTime)
      })
    }).observe({ entryTypes: ['first-input'] })

    // Cumulative Layout Shift
    let clsValue = 0
    new PerformanceObserver((list) => {
      const entries = list.getEntries()
      entries.forEach(entry => {
        if (!entry.hadRecentInput) {
          clsValue += entry.value
        }
      })
      console.log('CLS:', clsValue)
    }).observe({ entryTypes: ['layout-shift'] })
  }
}

// Initialize performance monitoring
export const initPerformance = () => {
  performanceMonitor.measureLoadTime()
  performanceMonitor.monitorVitals()
  lazyLoad.images()
  lazyLoad.components()
}
