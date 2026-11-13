class Admin::DashboardController < Admin::BaseController
  # Surface quick metrics that help admins decide what to do next
  def index
    @pending_count = User.where(approved: false, role: [:instructor, :admin]).count
  end
end
