class ProductsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_product, only: [:edit, :update, :show, :destroy]
    before_action :authorize!, only: [:edit, :update, :destroy]

    def new
        @product = Product.new
    end
    def create
        @product = Product.new product_params
        @product.user = current_user
        if @product.save # perform validation and if succesful it will save indb
            flash[:notice] = 'Product Created Successfully'
            redirect_to product_path(@product)
        else
            render :new
        end
    end
    
    def index 
        @products = Product.all.order('created_at DESC')
    end

    def show
        @new_review = Review.new
        if can? :crud, @product
            @reviews = @product.reviews.order(created_at: :desc)
        else
            @reviews = @product.reviews.where(hidden: false).order(created_at: :desc)
        end
        @favourite = @product.favourites.find_by(user: current_user)
    end

    def edit    
    end

    def update
        
        if @product.update product_params
            flash[:notice] = 'Updated Successfully'
            redirect_to product_path(@product)
        else
            render :edit
        end
    end

    def destroy
        @product.destroy
        redirect_to products_path
    end 

    def favourited 
        @products = current_user.favourited_products.order('favourites.created_at DESC')
    end

    private

    def product_params
        params.require(:product).permit(:title, :description, :price)
    end

    def find_product
        @product=Product.find params[:id]
    end

    def authorize!
        unless can?(:crud, @product)
        #if permission given by cancan above, authorize, else below
        #basically asking is the question user is equal to current user
        redirect_to root_path, alert: "Not Authorized"
        end
    end
    
end
