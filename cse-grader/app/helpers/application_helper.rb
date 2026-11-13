module ApplicationHelper
  include Pagy::Frontend
  
  # OSU-specific helper methods for consistent styling and functionality

  # Generate OSU logo with proper branding
  def osu_logo(size: :medium)
    case size
    when :small
      content_tag :div, "OSU", class: "bg-scarlet text-white font-bold text-sm px-2 py-1 rounded mr-2"
    when :medium
      content_tag :div, "OSU", class: "bg-scarlet text-white font-bold text-lg px-3 py-1 rounded mr-3"
    when :large
      content_tag :div, "OSU", class: "bg-scarlet text-white font-bold text-2xl px-4 py-2 rounded mr-4"
    end
  end

  # Generate status badges with consistent styling
  def status_badge(status, options = {})
    base_classes = "status-badge"
    status_classes = case status.to_s.downcase
    when 'approved', 'active'
      "status-approved"
    when 'pending', 'waiting'
      "status-pending"
    when 'rejected', 'inactive'
      "status-rejected"
    else
      "bg-gray-100 text-gray-800"
    end

    content_tag :span, status.to_s.capitalize, 
                class: "#{base_classes} #{status_classes} #{options[:class]}"
  end

  # Generate role badges
  def role_badge(role, options = {})
    base_classes = "role-badge"
    role_classes = case role.to_s.downcase
    when 'instructor'
      "role-instructor"
    when 'admin', 'administrator'
      "role-admin"
    else
      "bg-gray-100 text-gray-800"
    end

    content_tag :span, role.to_s.capitalize, 
                class: "#{base_classes} #{role_classes} #{options[:class]}"
  end

  # Generate user avatar
  def user_avatar(user, options = {})
    size = options[:size] || :medium
    size_classes = case size
    when :small
      "w-8 h-8 text-sm"
    when :medium
      "w-10 h-10 text-lg"
    when :large
      "w-12 h-12 text-xl"
    end

    initials = (user.name || user.email).first.upcase
    content_tag :div, initials, 
                class: "user-avatar #{size_classes} #{options[:class]}"
  end

  # Generate flash messages with proper styling
  def render_flash_messages
    return unless flash.any?

    content_tag :div, class: "flash-messages" do
      flash.map do |type, message|
        content_tag :div, class: "flash-message #{type}" do
          content_tag :div, class: "flash-content" do
            icon = case type.to_s
            when 'notice', 'success'
              '✓'
            when 'alert', 'error'
              '✗'
            else
              'ℹ'
            end

            content_tag(:span, icon, class: "flash-icon") +
            content_tag(:span, message)
          end
        end
      end.join.html_safe
    end
  end

  # Generate page headers with consistent styling
  def page_header(title, subtitle = nil, options = {})
    content_tag :div, class: "page-header #{options[:class]}" do
      content_tag(:h1, title, class: "page-header h1") +
      (subtitle ? content_tag(:p, subtitle, class: "page-header p") : "")
    end
  end

  # Generate stat cards for dashboard
  def stat_card(number, label, options = {})
    content_tag :div, class: "stat-card #{options[:class]}" do
      content_tag(:div, number, class: "stat-number") +
      content_tag(:div, label, class: "stat-label")
    end
  end

  # Generate empty state
  def empty_state(icon: "📋", title: "No data", description: "There's nothing to show here yet.", actions: [])
    content_tag :div, class: "empty-state" do
      content_tag(:div, icon, class: "empty-state-icon") +
      content_tag(:h3, title) +
      content_tag(:p, description) +
      (actions.any? ? content_tag(:div, actions.join.html_safe, class: "mt-6") : "")
    end
  end

  # Generate form input with consistent styling
  def form_input(f, field, options = {})
    input_classes = "form-input #{options[:class]}"
    label_classes = "form-label #{options[:label_class]}"
    
    content_tag :div, class: "form-group #{options[:wrapper_class]}" do
      f.label(field, options[:label] || field.to_s.humanize, class: label_classes) +
      f.text_field(field, class: input_classes, placeholder: options[:placeholder])
    end
  end

  # Generate button with consistent styling
  def button_primary(text, options = {})
    button_classes = "btn-primary #{options[:class]}"
    content_tag :button, text, 
                class: button_classes,
                type: options[:type] || "button",
                data: options[:data]
  end

  def button_secondary(text, options = {})
    button_classes = "btn-secondary #{options[:class]}"
    content_tag :button, text, 
                class: button_classes,
                type: options[:type] || "button",
                data: options[:data]
  end

  def button_danger(text, options = {})
    button_classes = "btn-danger #{options[:class]}"
    content_tag :button, text, 
                class: button_classes,
                type: options[:type] || "button",
                data: options[:data]
  end

  # Format dates consistently
  def format_date(date, format: :short)
    return "N/A" unless date

    case format
    when :short
      date.strftime("%b %d, %Y")
    when :long
      date.strftime("%B %d, %Y")
    when :time
      date.strftime("%b %d, %Y at %I:%M %p")
    else
      date.to_s
    end
  end

  # Generate breadcrumbs
  def breadcrumbs(items)
    return unless items.any?

    content_tag :nav, class: "breadcrumbs mb-6" do
      items.map.with_index do |item, index|
        if index == items.length - 1
          content_tag :span, item[:text], class: "text-gray-600 font-medium"
        else
          link_to(item[:text], item[:url], class: "text-scarlet hover:text-scarlet-dark") +
          content_tag(:span, " / ", class: "mx-2 text-gray-400")
        end
      end.join.html_safe
    end
  end

  # Check if user has permission
  def can?(action, resource = nil)
    return true if current_user&.admin?
    return false unless current_user

    case action
    when :manage_users
      current_user.admin?
    when :view_admin
      current_user.admin?
    when :manage_courses
      current_user.admin? || current_user.instructor?
    else
      true
    end
  end

  # Generate pagination info
  def pagination_info(pagy)
    return unless pagy

    start_item = (pagy.page - 1) * pagy.limit + 1
    end_item = [pagy.page * pagy.limit, pagy.count].min

    "Showing #{start_item}-#{end_item} of #{pagy.count} results"
  end

  def pagy_nav_styled(pagy)
    html = pagy_nav(pagy)
    content_tag(:div, html.html_safe, class: 'pagy-nav-wrapper')
  end
end