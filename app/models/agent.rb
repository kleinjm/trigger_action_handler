class Agent < ActiveRecord::Base
  has_many :deals
  has_many :leads
  has_many :showings
  has_many :agent_contacts
  has_many :assigned_events, :class_name => "Event", :as => :assignee
  has_many :created_events, :class_name => "Event", :as => :creator
  has_many :assigned_tasks, :class_name => "Task", :as => :assignee
  has_many :created_tasks, :class_name => "Task", :as => :creator
  has_many :completed_tasks, :class_name => "Task", :as => :completer
end
