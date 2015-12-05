class UserBuilding < ActiveRecord::Base
  has_many :units
  validates :address, presence: true
  validates :lat, numericality: true
  validates :lon, numericality: true
end
