class FieldValuePair < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
end