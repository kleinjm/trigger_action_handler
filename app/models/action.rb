class Action < ActiveRecord::Base
  has_one :lookup_field_val_pair, class_name: "FieldValuePair", as: :owner
  has_many :change_field_val_pair, class_name: "FieldValuePair", as: :owner

  belongs_to :crud_action
  belongs_to :trigger
end