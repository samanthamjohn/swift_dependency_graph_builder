class FileDependency < ActiveRecord::Base
  belongs_to :dependency
  belongs_to :swift_file
  scope :depends, -> { where("dependent_or_provider = ?", SwiftFile::DEPENDENT) }
  scope :provides, -> { where("dependent_or_provider = ?", SwiftFile::PROVIDER) }

end
