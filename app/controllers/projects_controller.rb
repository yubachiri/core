class ProjectsController < ApplicationController
  before_action :pundit_auth
  after_action :verify_authorized


  def index
    # ユーザが閲覧可能なプロジェクトの一覧を表示する
    Project.get_visible_projects current_user
  end

  def new
  end

  def create
  end

  def show
  end

  private

  def pundit_auth
    authorize Project
  end
end
