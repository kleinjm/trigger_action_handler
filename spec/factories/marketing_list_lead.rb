FactoryGirl.define do
  factory :marketing_list_lead do
    marketing_list{ create :marketing_list }
    lead{ create :lead }
  end
end