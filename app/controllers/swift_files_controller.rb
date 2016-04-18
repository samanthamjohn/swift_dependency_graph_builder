
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
      .where("dependency_type <> ?", SwiftFile::EXTERNAL)
      .where("dependency_type <> ?", SwiftFile::MEMBER)
      .where("value LIKE '%9hopscotch%'")

    @depends = @swift_file.depends
      .where("dependency_type <> ?", SwiftFile::EXTERNAL)
      .where("dependency_type <> ?", SwiftFile::MEMBER)
      .where("value LIKE '%9hopscotch%'")
  end
end
