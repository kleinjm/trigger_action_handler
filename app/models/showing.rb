class Showing < ActiveRecord::Base
  belongs_to :lead
  belongs_to :agent
end
