
class SwiftFilesController < ApplicationController
  def index

    file_query =<<-SQL
    SELECT
    swift_files.id as swift_id,
    swift_files.filename as filename,

    file_provides_dependencies.id,
    file_provides_dependencies.swift_file_id,
    file_provides_dependencies.dependency_id,
    file_provides_dependencies.dependent_or_provider,

    provides_dependencies.id,

    file_depends_dependencies.id,
    file_depends_dependencies.dependency_id,
    file_depends_dependencies.swift_file_id,
    file_depends_dependencies.dependent_or_provider,

    COUNT(DISTINCT dependent_files.id) as count,
    dependent_files.id

    FROM swift_files
    JOIN file_dependencies as file_provides_dependencies
    ON file_provides_dependencies.swift_file_id = swift_files.id

    JOIN dependencies as provides_dependencies
    ON file_provides_dependencies.dependency_id = provides_dependencies.id

    JOIN file_dependencies as file_depends_dependencies
    ON file_depends_dependencies.dependency_id = provides_dependencies.id

    JOIN swift_files as dependent_files
    ON dependent_files.id = file_depends_dependencies.swift_file_id

    WHERE file_provides_dependencies.dependent_or_provider = 'provider'
    AND file_depends_dependencies.dependent_or_provider = 'dependent'

    GROUP BY swift_files.id

    ORDER BY count DESC

    SQL

    @file_provides = SwiftFile.connection.execute(file_query)

    # @file_provides = FileDependency.provides
      # .joins(:dependency)
      # .joins(:"dependency.depends_files")
      # .select('count(swift_file_id) as count,
      # swift_file_id,
      # swift_files.filename as filename')
      # .group('swift_file_id')
      # .order('count DESC')
      # .limit(200)

    # @file_provides = FileDependency
      # .provides
      # .joins(:swift_file)
      # .select('count(swift_file_id) as count,
      # swift_file_id,
      # swift_files.filename as filename')
      # .group('swift_file_id')
      # .order('count DESC')
      # .limit(200)
  end

  def show
    @swift_file = SwiftFile.find(params[:id])
    @provides = @swift_file.provides
      .where("dependency_type <> ?", SwiftFile::EXTERNAL)
      .where("dependency_type <> ?", SwiftFile::MEMBER)
    @provides_files =
      @provides.map(&:depends_files).flatten.uniq
    @provides = @provides.flatten.uniq

    @depends = @swift_file.depends
      .where("dependency_type <> ?", SwiftFile::EXTERNAL)
      .where("dependency_type <> ?", SwiftFile::MEMBER)
  end
end
