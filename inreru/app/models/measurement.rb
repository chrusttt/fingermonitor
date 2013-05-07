class Measurement < ActiveRecord::Base
  attr_accessible :date, :grade, :trial_id
  belongs_to :trial
end
