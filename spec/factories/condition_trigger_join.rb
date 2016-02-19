FactoryGirl.define do
  factory :condition_trigger_join do
    trigger{ create :trigger }
    condition{ create :condition }
    operator "||"
  end
end