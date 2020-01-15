class NewsArticlesController < ApplicationController
  before_action :find_news_article, only: [:edit, :update, :show, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :destroy, :edit, :update]
  before_action :authorize!, only: [:edit, :update]
  def index
    @news_articles = NewsArticle.order(created_at: :DESC)
  end

  def show
  end


  def new
   @news_article = NewsArticle.new
  end

  def create
   @news_article = NewsArticle.new news_article_params
   @news_article.user = current_user
   if @news_article.save
    flash[:notice] = 'Article created!'
    redirect_to @news_article
   else
    render :new
   end
  end

  def edit
    render :edit
    @news_article = NewsArticle.find params[:id] 
  end

  def update
   if @news_article.update news_article_params
    flash[:notice] = 'Article updated!'
    redirect_to @news_article
   else
    flash[:alert] = 'Something went wrong, see errors below.'
    render :edit
   end
  end

  def destroy
   @news_article = NewsArticle.find(params[:id])
   if can? :crud, @news_article
   #if we put can? :crud here, don't put :destroy above in before action
   @news_article.destroy
   flash[:alert] = 'Article deleted!'
   redirect_to news_articles_path
   else
    flash[:danger] = "Access Denied"
    redirect_to @news_article
   end
  end

  private
  def find_news_article
    @news_article = NewsArticle.find params[:id]
  end

  def news_article_params
    params.require(:news_article).permit(:title, :description, :published_at, :view_count)
  end

  def authorize!
    unless can?(:crud, @news_article)
      #if permission given by cancan above, authorize, else below
      #basically asking is the question user is equal to current user
      redirect_to root_path
      flash[:danger] = "Not Authorized"
    end
  end

  def news_article_params
    params.require(:news_article).permit(:title, :description, :id)
  end

end