class Admin::BaseController < ApplicationController
  # All admin controllers inherit this guard to enforce elevated access
  before_action -> { require_role!(:admin) }
end
