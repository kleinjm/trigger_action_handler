FactoryGirl.define do
  factory :condition do
    trigger{ create :trigger }
    operator "=="
    
    after(:create) do |condition|
      create :field_value_pair, owner: condition
    end
  end
end