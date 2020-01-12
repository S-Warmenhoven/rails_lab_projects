class NewsArticlesController < ApplicationController
before_action :find_news_article, only: [:edit, :update, :show, :destroy]

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
   if @news_article.save
    flash[:notice] = 'Article created!'
     redirect_to @news_article
   else
     render :new
   end
 end

 def edit
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
   @news_article.destroy
   flash[:alert] = 'Article deleted!'
   redirect_to news_articles_path
 end

 private
  def find_news_article
    @news_article = NewsArticle.find params[:id]
  end

  def news_article_params
    params.require(:news_article).permit(:title, :description, :published_at, :view_count)
  end


end