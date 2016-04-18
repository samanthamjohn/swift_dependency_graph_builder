class Dependency < ActiveRecord::Base
  has_many :file_providers, -> { where("dependent_or_provider = '#{PROVIDER}'") }, class_name: "FileDependency"
  has_many :provides_files, through: :file_providers, class_name: "SwiftFile", source: :swift_file

  has_many :file_depends, -> { where("dependent_or_provider = '#{DEPENDENT}'") }, class_name: "FileDependency"
  has_many :depends_files, through: :file_depends, class_name: "SwiftFile", source: :swift_file
end
