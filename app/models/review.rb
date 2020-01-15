class Review < ApplicationRecord
  #Association
  belongs_to :user
  belongs_to :product
  has_many :likes, dependent: :destroy
  
  has_many :likers, through: :likes, source: :user

  #Validations
  validates :rating, numericality: {greater_than: 0, less_than: 6, presence: true}
end
