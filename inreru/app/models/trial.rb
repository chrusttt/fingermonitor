class Trial < ActiveRecord::Base
  
  belongs_to :user
  has_many :measurements
  accepts_nested_attributes_for :measurements
  attr_accessible :date, :name, :user_id, :measurements_attributes
end

