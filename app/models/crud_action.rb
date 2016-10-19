class CrudAction < ActiveRecord::Base
  validates_presence_of :name

  def self.names
    CrudAction.all.pluck(:name)
  end
end
