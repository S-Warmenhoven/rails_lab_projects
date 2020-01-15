class User < ApplicationRecord
    has_many :products, dependent: :nullify
    has_many :reviews, dependent: :nullify
    has_many :news_articles, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :liked_reviews, through: :likes, source: :review
    
    has_many :favourites, dependent: :destroy
    has_many :favourited_products, through: :favourites, source: :product
    
    has_secure_password
    
    validates :email, presence: true, uniqueness: true, 
    format: /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    
    #above is available because we uncommented the bcrypt gem
    validates :first_name, :last_name, presence: true
    
    def full_name
        "#{first_name} #{last_name}".strip
    end

end
