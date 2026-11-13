// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { initPerformance } from "./utils/performance"
import "./view_sections";
// Initialize performance monitoring
document.addEventListener('DOMContentLoaded', initPerformance)
