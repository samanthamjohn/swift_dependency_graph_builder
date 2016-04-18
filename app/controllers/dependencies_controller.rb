class DependenciesController < ApplicationController
  def index
    # @dependents = Dependency.paginate(page: params[:page])

    @file_depends = FileDependency
      .depends
      .joins(:dependency)
      .select('count(dependency_id) as count,
      dependency_id,
      dependencies.value as value,
      dependencies.dependency_type as type')
      .where("type <> ?", SwiftFile::EXTERNAL)
      .where("type <> ?", SwiftFile::MEMBER)
      .where("value LIKE '%9hopscotch%'")
      .group('dependency_id')
      .order('count DESC')
      .limit(50)
      # .where("type = ?", SwiftFile::NOMINAL)

  end

  def show
    @dependency = Dependency.find(params[:id])
    @providers = @dependency.provides_files
    @dependents = @dependency.depends_files
  end

end
