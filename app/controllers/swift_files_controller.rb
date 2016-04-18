
class SwiftFilesController < ApplicationController
  def index
    @file_provides = FileDependency
      .provides
      .joins(:swift_file)
      .select('count(swift_file_id) as count,
      swift_file_id,
      swift_files.filename as filename')
      .group('swift_file_id')
      .order('count DESC')
      .limit(200)
  end

  def show
    @swift_file = SwiftFile.find(params[:id])
    @provides = @swift_file.provides
  end
end
