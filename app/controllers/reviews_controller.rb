class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_review, only: [:destroy, :edit, :update, :toggle_hidden]
  before_action :authorize!, only: [:edit, :update, :destroy]
  before_action :authorize_toggle!, only: [:toggle_hidden]

    def create
        @product = Product.find(params[:product_id])
        @new_review = Review.new review_params
        @new_review.user = current_user
        @new_review.product = @product
        if @new_review.save
            redirect_to product_path(@product) #can also just say @product
        else
            @reviews = @product.reviews.order(created_at: :desc)
            render 'products/show'    
        end
    end
    #new is not necessary because create creates new
    #and new is just for display purposes which we don't need
    #for answers because we have no seperate view page

    def edit
        @review=Review.find params[:id] 
        render :edit
    end

    def update
        #@product=Product.find(params[:product_id])
        @review=Review.find params[:id]
        #if can? :crud, @review
            if @review.update review_params
                flash[:notice] = 'Updated Successfully'
                redirect_to product_path(@review.product)
            else
                render :edit
            end
        #else
        #    redirect_to root_path, alert: "Not authorized" 
        #end
    end

    def destroy
        #@product = Product.find(params[:product_id])
        @review = Review.find(params[:id])
        #if can? :crud, @review
        #@review = Review.find(params[:id])
        #@review = @product.reviews.find(params[:id])
        @review.destroy 
        redirect_to product_path(@review.product) #or just @review.product
        #else
        #    redirect_to root_path, alert: "Not authorized"
        #end
    end

    def toggle_hidden
        #update the boolean field 'hidden' to whatever it isn't currently
        @review.update(hidden: !@review.hidden?)
        redirect_to product_path(@review.product), notice: "Review #{@review.hidden ? 'hidden' : 'shown'}."
    end

    private
    #non-private methods in a controller are actions
    #anything that is not an action, should be private
    def find_review
        @review = Review.find(params[:id])
    end
    
    def authorize!
      redirect_to root_path, alert: "access denied" unless can? :crud, @review
    end

    def authorize_toggle!
      redirect_to root_path, alert: "access denied" unless can? :crud, @review.product
    end

    def review_params
        params.require(:review).permit(:rating, :body, :id)
    end
end