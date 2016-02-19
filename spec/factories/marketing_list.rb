FactoryGirl.define do
  factory :marketing_list do
    agent{ create :agent }
    name "A small list"
  end
end