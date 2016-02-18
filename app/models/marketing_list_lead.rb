class MarketingListLead < ActiveRecord::Base
  belongs_to :marketing_list
  belongs_to :lead
end
