FactoryGirl.define do
  factory :showing do
    lead{ create :lead }
    agent{ create :agent }
    comments "this is a good showing"
  end
end