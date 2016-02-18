class Event < ActiveRecord::Base
  belongs_to :creator, :class_name => 'Agent'
  belongs_to :assignee, :class_name => 'Agent'
  belongs_to :lead
  belongs_to :deal
  validates_presence_of :creator_id
  validates_presence_of :assignee_id
end
