class AgentContact < ActiveRecord::Base
  belongs_to :agent
  belongs_to :lead
  validates_presence_of :lead_id
  validates_presence_of :agent_id
end
