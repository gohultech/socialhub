class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query].present?
      @users = User.joins(:profile)
                   .where("profiles.username ILIKE ?", "%#{params[:query]}%")
    else
      @users = []
    end
  end
end