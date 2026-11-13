# Ensure a default admin account exists for local development and automated boots.
# Override email/password via DEFAULT_ADMIN_EMAIL / DEFAULT_ADMIN_PASSWORD env vars if needed.
Rails.application.config.to_prepare do
  default_email    = ENV.fetch("DEFAULT_ADMIN_EMAIL", "admin.1@osu.edu")
  default_password = ENV.fetch("DEFAULT_ADMIN_PASSWORD", "AdminPassword123!")

  begin
    User.find_or_create_by!(email: default_email) do |user|
      user.password              = default_password
      user.password_confirmation = default_password
      user.role                  = :admin
      user.approved              = true
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid, ActiveRecord::ConnectionNotEstablished => e
    Rails.logger.warn("Default admin bootstrap skipped: #{e.class} #{e.message}")
  end
end
