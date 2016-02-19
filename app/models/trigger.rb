class Trigger < ActiveRecord::Base
  
  belongs_to :crud_action

  has_many :condition_trigger_joins
  has_many :conditions, through: :condition_trigger_joins
  
  has_many :actions

  validates_presence_of :crud_action_id, :klass
end