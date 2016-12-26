class BorkedProjectLink < ActiveRecord::Base
  belongs_to :borked_to_project, class_name: Project
  belongs_to :borked_from_project, class_name: Project
end
