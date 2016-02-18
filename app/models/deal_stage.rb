class DealStage < ActiveRecord::Base
  has_many :deals, :as => :current_stage
end
