class FileDependency < ActiveRecord::Base
  belongs_to :dependency
  belongs_to :swift_file

end
