class Product < ApplicationRecord
  #Associations
  belongs_to :user
  has_many :reviews, dependent: :destroy

  #Call Backs - Rails HOOK
  before_validation :set_default_price
  before_save :capitalize_title #before saving a record, execute the capitalize_title method
    
    
  #Validations: 
  #Rails has built in methods which allow us to create validations really easily
  validates :title, presence: true, uniqueness: true, case_sensitive: false
  validates :description, presence: true, length: {minimum: 10}
  #must be greater than zero
  validates :price, numericality: {greater_than: 0}

  #Custom Methods
  # By convention, it's preferable to use the keyword `lambda` instead of `->` for multiline blocks
  # scope(:search, ->(query){where("title ILIKE?","%#{query}%")})
  #Long way:
  scope :search, lambda { |query|
    where("title ILIKE '%#{query}%' OR description ILIKE '%#{query}%'")
      .order(
        # Order first by products whose titles that contain the `query`
        "title ILIKE '%#{query}%' DESC",
        # Then, if a product's title and description contain the `query`,
        # put products whose descriptions also contain the `query` later in results
        "description ILIKE '%#{query}%' ASC"
      )
  }

    private

    def capitalize_title
        self.title.capitalize!
    end

    def set_default_price
        self.price ||= 1.00
        #we put .00 to make it 2 decimal
    end

end
