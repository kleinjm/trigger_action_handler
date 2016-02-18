class Deal < ActiveRecord::Base
  belongs_to :lead
  belongs_to :agent
  belongs_to :current_stage, :class_name => 'DealStage'
  has_many :events
  has_many :tasks
  validates_presence_of :lead_id
  validates_presence_of :agent_id
  validates_presence_of :property_id
end
