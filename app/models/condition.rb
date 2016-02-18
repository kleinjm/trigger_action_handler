class Condition < ActiveRecord::Base

  belongs_to :trigger
  has_one :field_value_pair, as: :owner

end