class PropertyView < ActiveRecord::Base
  belongs_to :lead
  validates_presence_of :lead_id
  validates_presence_of :property_id
 end
