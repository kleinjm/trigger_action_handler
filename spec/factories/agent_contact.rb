FactoryGirl.define do
  factory :agent_contact do
    property_id 1
    comments "hey, I'm a cool lead"
    lead{ create :lead }
    agent{ create :agent }
  end
end