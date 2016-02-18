class Task < ActiveRecord::Base
  belongs_to :creator, :class_name => 'Agent'
  belongs_to :assignee, :class_name => 'Agent'
  belongs_to :completer, :class_name => 'Agent'
  belongs_to :lead
  belongs_to :deal
  belongs_to :task_priority
  belongs_to :task_status
  validates_presence_of :creator_id
  validates_presence_of :assignee_id
end
