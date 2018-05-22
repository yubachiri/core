class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @project = Project.find(params[:project_id])
    @participants = @project.users
    authorize @project, :show_user_index?
  end

end
