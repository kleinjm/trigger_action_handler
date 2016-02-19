FactoryGirl.define do
  factory :condition do
    operator "=="
    
    after(:create) do |condition|
      create :field_value_pair, owner: condition
    end
  end
end