class LikesController < ApplicationController
    before_action :authenticate_user!
    before_action :find_review, only: [:create]
    before_action :authorize!, only: [:create]

    def create
        #we don't need instance variables if we 
        #don't need them in the views but we do
        #now, so use them
        like = Like.new(user: current_user, review: @review)
        if like.save 
            flash[:success] = "Question Liked"
        else 
            flash[:danger] = like.errors.full_messages.join(", ")
        end
        redirect_to product_path(@review.product)
        # the above is the same as: 
        # `redirect_to question_path(@question)`
    end

    def destroy
        like = Like.find params[:id]
        if can? :destroy, like
            like.destroy 
            flash[:success] = 'Review Unliked'
            redirect_to product_path(like.review.product)
        else 
            flash[:alert] = "Can't delete like!"
        end
    end

    private 

    def find_review 
        @review = Review.find params[:review_id]
    end

    def authorize!
        unless can?(:like, @review)
            flash[:danger] = "Don't be a narcissist"
            redirect_to product_path(@review.product)
        end
    end
end
