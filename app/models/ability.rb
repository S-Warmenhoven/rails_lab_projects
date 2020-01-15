# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)

    if user.is_admin?
      can :manage, :all
    else
      can :read, :all
    end

    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    alias_action :create, :read, :update, :destroy, to: :crud

    can :crud, Product do |product|
      product.user == user #user in this case is current_user because Cancan is checking that automatically
      #we are checking to see if this question user is the current user 
      #:manage means you can do anything. so, even if you unauthorize something
      #later, this will override. so, instead, use :crud
    end

    can :crud, Review do |review|
      review.user == user  #|| review.product.user == user 
      #in this case only the answer owner can manage the answer, but if you do ||
      # then answer and question owner can manage
    end

    can :crud, NewsArticle do |news_article|
      news_article.user == user
    end

    can :like, Review do |review|
      user.persisted? && review.user != user
      #persisted makes sure user is signed in
      #so guest users can't like
    end
    # Can also write abilities like: 
    # can :manage, Question, user_id: user.id

    can :destroy, Like do |like|
      like.user = user
    end

    can :favourite, Product do |product|
      user.persisted? && product.user != user
      #persisted makes sure user is signed in
      #so guest users can't favourite
    end
    # Can also write abilities like: 
    # can :manage, Question, user_id: user.id

    can :destroy, Favourite do |favourite|
      favourite.user = user
    end
    
  end
end
