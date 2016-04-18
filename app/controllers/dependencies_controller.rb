class DependenciesController < ApplicationController
  def index
    @dependents = Dependency.paginate(page: params[:page])
  end

end
