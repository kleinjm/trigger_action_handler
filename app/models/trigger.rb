class Trigger < ActiveRecord::Base
  belongs_to :crud_action

  has_many :condition_trigger_joins
  has_many :conditions, through: :condition_trigger_joins, dependent: :destroy

  has_many :actions, dependent: :destroy

  validates_presence_of :crud_action, :klass
end
