class Action < ActiveRecord::Base
  has_one :lookup_field_value_pair, -> { where identifier: 'lookup' },
          class_name: FieldValuePair, as: :owner
  has_many :change_field_value_pairs, -> { where identifier: 'change' },
           class_name: FieldValuePair, as: :owner

  belongs_to :crud_action
  belongs_to :trigger

  validates_presence_of :trigger, :crud_action, :klass
end
