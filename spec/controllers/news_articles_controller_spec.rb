require 'rails_helper'

RSpec.describe NewsArticlesController, type: :controller do
    describe '#new' do

        it 'should render the new template' do
            # GIVEN
            # Defaults
            # WHEN 
            # Making a GET request to the new action 
             get(:new)
            # THEN
            # The `response` contains the rendered template of `new`
            #
            # The `response` object is available in any controller. It 
            # is similar to the `response` available in Express 
            # Middleware, however we rarely interact with it directly in 
            # Rails. RSpec makes it available when testing 
            # so that we can verify its contents. 
            
            # Here we verify with the `render_template` matcher that it 
            # contains the right rendered template. 
            expect(response).to(render_template(:new)) 
        end

        it 'should set an instance variable with a new news article' do
            get(:new)

            assigns(:news_article)
            # Return the value of an instance variable @news_article 
            # from the instance of our NewsArticlesController. 
            # Only available if we have added the 
            # gem 'rails-controller-testing
            
            expect(assigns(:news_article)).to(be_a_new(NewsArticle))
            # The above matcher will verify that the expected value 
            # is a new instance of the NewsArticle Class(/Model)    
        end
    end

    describe '#create' do
        # `context` the functionally the same as `describe`, 
        # but we generally use it to organize groups of 
        # branching code paths
        context 'with valid parameters' do
            def valid_request 
                # The post method below simulates an HTTP request to 
                # the create action of the NewsArticlesController using 
                # the POST verb. 

                # This effectively simulates a user filling out a new
                # form in the browser and pressing submit. 
                post(:create, params: { news_article: FactoryBot.attributes_for(:news_article)})
            end
        

            it 'should create a new news_article in the db' do
                count_before = NewsArticle.count
                valid_request
                count_after = NewsArticle.count 
                expect(count_after).to eq(count_before + 1)
            end
            it 'should redirect to the show page of that news article' do
                valid_request
                expect(response).to redirect_to(news_article_path(NewsArticle.last))
            end
       
            it 'should set a flash message' do
              valid_request
              expect(flash[:notice]).to be
            end
        end    
       
        context 'with invalid parameters' do
          def invalid_request
            post :create, params: {
              news_article: FactoryBot.attributes_for(:news_article, title: nil)
            }
          end
       
            it "should not create a news article in the database" do
              count_before = NewsArticle.count
              invalid_request
              count_after = NewsArticle.count
              expect(count_after).to eq(count_before)
            end
        
            it "should render the new template" do
              invalid_request
              expect(response).to render_template(:new)
            end
        end
    end
       
    describe '#destroy' do
       
        before do
          @news_article = FactoryBot.create(:news_article)
        end
    
        it 'should remove a record from the database' do
          count_before = NewsArticle.count
          delete :destroy, params: {id: @news_article.id}
          count_after = NewsArticle.count
          expect(count_after).to eq(count_before - 1)
        end
       
        it 'should redirect to the index' do
          delete :destroy, params: {id: @news_article.id}
          expect(response).to redirect_to news_articles_path
        end
       
           it 'should set a flash message' do
             delete :destroy, params: {id: @news_article.id}
             expect(flash[:alert]).to be
           end
    end
       
    describe '#show' do
       it "should render the show template" do
         news_article = FactoryBot.create(:news_article)
         get :show, params: { id: news_article.id }
         expect(response).to render_template(:show)
       end
    
       it "should set an instance variable based on the article id that is passed" do
         news_article = FactoryBot.create(:news_article)
         get :show, params: { id: news_article.id }
         expect(assigns(:news_article)).to eq(news_article)
       end
    end
       
    describe '#index' do
    
       before do
         get :index
       end
    
       it "should render the index template" do
         expect(response).to render_template(:index)
       end
    
       it "should assign an instance variable to all created news articles (sorted by created_at)" do
         news_article_1 = FactoryBot.create(:news_article)
         news_article_2 = FactoryBot.create(:news_article)
         expect(assigns(:news_articles)).to eq([news_article_2, news_article_1])
       end
    end
    describe "#edit" do

      it "should render the edit template" do
        news_article = FactoryBot.create(:news_article)
        get :edit, params: { id: news_article.id }
        expect(response).to render_template :edit
      end
       
      it "should set an instance variable based on the article id that is passed" do
        news_article = FactoryBot.create(:news_article)
        get :edit, params: { id: news_article.id }
        expect(assigns(:news_article)).to eq(news_article)
      end
    end
       
    describe "#update" do

      before do
        @news_article = FactoryBot.create(:news_article)
      end

      context 'with valid parameters' do
            it "should update the news article record with new attributes" do
              new_title = "#{@news_article.title} Plus Changes!"
              patch :update, params: {id: @news_article.id, news_article: {title: new_title}}
              expect(@news_article.reload.title).to eq(new_title)
            end
       
            it "should redirect to the news article show page" do
              new_title = "#{@news_article.title} plus changes!"
              patch :update, params: {id: @news_article.id, news_article: {title: new_title}}
              expect(response).to redirect_to(@news_article)
            end
        end
       
        context 'with invalid parameters' do
            def invalid_request
              patch :update, params: {id: @news_article.id, news_article: {title: nil}}
            end
    
            it "should not update the news article with new attributes" do
              expect { invalid_request }.not_to change { @news_article.reload.title }
            end
       
            it "renders the edit template" do
              invalid_request
              expect(response).to render_template(:edit)
            end
        end
    end
end