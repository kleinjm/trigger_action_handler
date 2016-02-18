class MarketingList < ActiveRecord::Base
  belongs_to :agent
  has_many :marketing_list_leads
end
