FactoryGirl.define do
  factory :deal do
    lead { create :lead }
    agent { create :agent }
    property_id 1
  end
end