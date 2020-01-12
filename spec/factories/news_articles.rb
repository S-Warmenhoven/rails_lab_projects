FactoryBot.define do
  factory :news_article do
    # FactoryBot methods:
  
  # FactoryBot.attributes_for(:news_article)
  # Returns a plain hash of the parameters required to create 
  # a news article 
  # { 
  #   title: <generated from our factory below>, 
  #   description: <generated from our factory below>
  # }

  # FactoryBot.build(:news_article)
  # Returns a new unpersisted instance of a NewsArticle (using the factory)
  # FactoryBot.create(:news_article)
  # Returns a persisted instance of a NewsArticle (using the factory)

  # All your factories must always generate valid instances of 
  # your data. ALWAYS!
    
    sequence(:title) { |n| Faker::Quote.most_interesting_man_in_the_world + " #{n}" }
    description { Faker::Hacker.say_something_smart }
    
  end
end
