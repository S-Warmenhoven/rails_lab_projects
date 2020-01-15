class FavouritesController < ApplicationController
    before_action :authenticate_user!
    before_action :find_product, only: [:create]
    before_action :authorize!, only: [:create]

    def create
        #we don't need instance variables if we 
        #don't need them in the views but we do
        #now, so use them
        favourite = Favourite.new(user: current_user, product: @product)
        if favourite.save 
            flash[:success] = "Product Favoured"
        else 
            flash[:danger] = favourite.errors.full_messages.join(", ")
        end
        redirect_to @product
        # the above is the same as: 
        # `redirect_to question_path(@question)`
    end

    def destroy
        #like = Like.find params[:id]
        #above will look through all likes
        #below is more specific, so better
        favourite = Favourite.find params[:id]
        if can? :destroy, favourite
            favourite.destroy 
            flash[:success] = 'Not a fan!'
            redirect_to product_path(favourite.product)
        else 
            flash[:alert] = "Can't delete favourite!"
        end
    end

    private 

    def find_product 
        @product = Product.find params[:product_id]
    end

    def authorize!
        unless can?(:favourite, @product)
            flash[:danger] = "Don't be a narcissist"
            redirect_to product_path(@product)
        end
    end
end
