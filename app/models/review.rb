class Review < ApplicationRecord
  #Association
  belongs_to :user
  belongs_to :product

  #Validations
  validates :rating, numericality: {greater_than: 0, less_than: 6, presence: true}
end
