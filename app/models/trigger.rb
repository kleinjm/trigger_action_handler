class Trigger < ActiveRecord::Base
  
  belongs_to :crud_action
  has_many :conditions
  has_many :actions

  validates_presence_of :crud_action_id, :klass
end