class Admin::CatalogsController < Admin::BaseController
  def reload; end

  def perform_reload
    subject = params[:subject_filter].presence || "cse"
    Rails.logger.info "Starting reload with term=#{params[:term]}, campus=#{params[:campus]}, subject=#{subject}"

    count = OsuClassesFetcher.fetch_and_save!(
      term: params[:term],
      campus: params[:campus],
      subject: subject
    )

    Rails.logger.info "Reload completed successfully with #{count} items"
    redirect_to reload_admin_catalog_path,
                notice: "Reloaded #{params[:term]} / #{params[:campus].to_s.upcase} (#{count} items)."
  rescue => e
    Rails.logger.error "Reload failed: #{e.class.name}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to reload_admin_catalog_path, alert: "Reload failed: #{e.message}"
  end

  def approvals
    # List unapproved elevated accounts so admins can review them oldest-first
    @pending = User.where(approved: false, role: [:instructor, :admin]).order(created_at: :asc)
  end

  def approve
    User.find(params[:user_id]).update!(approved: true)
    redirect_to approvals_admin_catalog_path, notice: "Approved."
  end

  # Remove pending account entirely when admin declines the request
  def deny
    User.find(params[:user_id]).destroy!
    redirect_to approvals_admin_catalog_path, notice: "Request denied."
  end
end
