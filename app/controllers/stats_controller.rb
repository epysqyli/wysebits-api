class StatsController < ApplicationController
  skip_before_action :authenticate_request

  def user_stats; end

  def trending; end
end
