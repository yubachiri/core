class ProjectsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  # before_action :pundit_auth, only: [:index]
  after_action :verify_authorized, only: [:show]

  def index
    # ユーザが閲覧可能なプロジェクトの一覧を表示する
    @owner_prj, @joined_prj = Project.get_visible_projects current_user
  end

  def new
  end

  def create
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
  end

  # private
  #
  # def pundit_auth
  #   authorize Project
  # end
end
