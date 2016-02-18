class Lead < ActiveRecord::Base
  belongs_to :agent
  belongs_to :lead_priority
  belongs_to :lead_status
  belongs_to :lead_type
  belongs_to :phone_1_type, :class_name => "PhoneType", :foreign_key => "phone_type_1"
  belongs_to :phone_2_type, :class_name => "PhoneType", :foreign_key => "phone_type_2"
  belongs_to :phone_3_type, :class_name => "PhoneType", :foreign_key => "phone_type_3"
  has_many :property_views
  has_many :showings
  has_many :agent_contacts
  has_many :events
  has_many :tasks
  has_many :marketing_list_leads
  has_many :marketing_lists, :through => :marketing_list_lead
end
