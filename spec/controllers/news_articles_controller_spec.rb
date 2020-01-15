require 'rails_helper'

RSpec.describe NewsArticlesController, type: :controller do

  def current_user
    @current_user ||= FactoryBot.create(:user)
  end

  describe '#new' do
    context 'with no user signed in' do 
      it 'should redirect to session#new' do
        get :new 
        expect(response).to redirect_to(new_session_path)
      end 
      it 'sets a flash danger message' do 
        get :new
        expect(flash[:danger]).to be
      end
    end
    context 'with user signed in' do
      before do 
        session[:user_id] = current_user.id
      end

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
  end

  describe '#create' do
    # `context` the functionally the same as `describe`, 
    # but we generally use it to organize groups of 
    # branching code paths
    
      def valid_request 
          # The post method below simulates an HTTP request to 
          # the create action of the NewsArticlesController using 
          # the POST verb. 

          # This effectively simulates a user filling out a new
          # form in the browser and pressing submit. 
          post(:create, params: { news_article: FactoryBot.attributes_for(:news_article)})
      end
      context 'with no user signed in' do 
        it 'should redirect to session#new' do
            valid_request 
            expect(response).to redirect_to(new_session_path)
        end 
        it 'sets a flash danger message' do 
            valid_request
            expect(flash[:danger]).to be
        end
      end
      context 'with user signed in' do
        before do
          # @current_user = FactoryBot.create(:user)
          # To simulate signing in a user, set a `user_id`
          # in the session. RSpec makes a controller's session 
          # available inside your tests
          session[:user_id] = current_user.id
        end

        context 'with valid parameters' do

          it 'should create a new news_article in the db' do
            count_before = NewsArticle.count
            valid_request
            count_after = NewsArticle.count 
            expect(count_after).to eq(count_before + 1)
          end
          it 'should redirect to the show page of that news article' do
            valid_request
            news_article = NewsArticle.last
            expect(response).to(redirect_to(news_article_path(news_article)))
          end
       
          it 'associates the current_user to the created NewsArticle' do
            valid_request
            news_article = NewsArticle.last
            expect(news_article.user).to eq(current_user)
          end
        end    
       
      context 'with invalid parameters' do
        def invalid_request
          post :create, params: {
            news_article: FactoryBot.attributes_for(:news_article, title: nil)
          }
        end

        it 'should assign an invalid news_article as an instance variable' do 
          invalid_request
          expect(assigns(:news_article)).to be_a(NewsArticle)
          expect(assigns(:news_article).valid?).to be(false)
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
  end
       
    describe '#destroy' do
      context 'with no user signed in' do  
        before do
          news_article = FactoryBot.create(:news_article)
          delete(:destroy, params: {id: news_article.id})
        end
        it 'should redirect to session#new' do
          expect(response).to redirect_to(new_session_path)
        end 
        it 'sets a flash danger message' do 
          expect(flash[:danger]).to be
        end
      end
      context 'with signed in user' do 
        before do 
            session[:user_id] = current_user.id
        end
        context 'as non-owner' do 
          it 'redirects to news article show' do 
            news_article = FactoryBot.create(:news_article)
            delete(:destroy, params: {id: news_article.id})
            expect(response).to redirect_to news_article_path(news_article)
            end
          it 'sets a flash danger' do
            news_article = FactoryBot.create(:news_article)
            delete(:destroy, params: {id: news_article.id})
            expect(flash[:danger]).to be
          end
          it 'does not remove a news article' do
            news_article = FactoryBot.create(:news_article)
            delete(:destroy, params: {id: news_article.id})
            expect(NewsArticle.find_by(id: news_article.id)).to eq(news_article)
            #.find throws an exception if finding nil
            #but .find_by will return nil
          end  
        end
        context 'as owner' do 
          it 'should remove a record from the database' do
          news_article = FactoryBot.create(:news_article, user: current_user)
          #count_before = NewsArticle.count
          delete :destroy, params: {id: news_article.id}
          expect(NewsArticle.find_by(id: news_article.id)).to be(nil)
          #count_after = NewsArticle.count
          #expect(count_after).to eq(count_before - 1)
          end
       
          it 'should redirect to the index' do
            news_article = FactoryBot.create(:news_article, user: current_user)
            delete :destroy, params: {id: news_article.id}
            expect(response).to redirect_to news_articles_path
          end
       
          it 'should set a flash message' do
            news_article = FactoryBot.create(:news_article, user: current_user)
            delete :destroy, params: {id: news_article.id}
            expect(flash[:alert]).to be
          end
        end
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
      context 'with no user signed in' do 
        it 'should redirect to session#new' do 
          news_article = FactoryBot.create(:news_article)
          get :edit, params: { id: news_article.id }
          expect(response).to redirect_to(new_session_path)
        end 
        it 'sets a flash danger message' do 
          news_article = FactoryBot.create(:news_article)
          get :edit, params: { id: news_article.id }
          expect(flash[:danger]).to be
        end
      end
      context 'with user signed in' do

        before do 
          session[:user_id] = current_user.id
        end

        context 'as non-owner' do
          it 'redirects to root_page' do
            news_article = FactoryBot.create(:news_article)
            get :edit, params: { id: news_article.id }
            expect(response).to redirect_to root_path
          end
          it 'alerts the user with a flash' do
            news_article = FactoryBot.create(:news_article)
            get :edit, params: { id: news_article.id }
            expect(flash[:danger]).to be
          end
          it 'does not edit a news article' do
            news_article = FactoryBot.create(:news_article)
            get :edit, params: { id: news_article.id }
            expect(NewsArticle.find_by(id: news_article.id)).to eq(news_article)
          end  
        end
        
        context 'as owner' do
          it "should render the edit template" do
            news_article = FactoryBot.create(:news_article, user: current_user)
            get :edit, params: { id: news_article.id }
            expect(response).to render_template :edit
          end
        
          it "should set an instance variable based on the article id that is passed" do
            news_article = FactoryBot.create(:news_article, user: current_user)
            get :edit, params: { id: news_article.id }
            expect(assigns(:news_article)).to eq(news_article)
          end
        end
      end
    end
       
    describe "#update" do

      def valid_request 
        patch :update, params: { id: @news_article.id, news_article: { title: "New Title" }}
      end

    context 'with no user signed in' do 
        it 'should redirect to session#new' do
          @news_article = FactoryBot.create(:news_article)
          valid_request 
          expect(response).to redirect_to(new_session_path)
        end 
        it 'sets a flash danger message' do 
          @news_article = FactoryBot.create(:news_article)
          valid_request
          expect(flash[:danger]).to be
        end
    end

    context 'with user signed in' do

      before do 
        session[:user_id] = current_user.id
      end

      context 'as non-owner' do
        it 'redirects to root_page' do
          @news_article = FactoryBot.create(:news_article)
          valid_request
          expect(response).to redirect_to root_path
        end
        it 'alerts the user with a flash' do
          @news_article = FactoryBot.create(:news_article)
          valid_request
          expect(flash[:danger]).to be
        end
        it 'does not update a news article' do
          @news_article = FactoryBot.create(:news_article)
          get :edit, params: { id: @news_article.id }
          expect(NewsArticle.find_by(id: @news_article.id)).to eq(@news_article)
        end  
      end

      context 'as owner' do
        before do
          @news_article = FactoryBot.create(:news_article, user: current_user)
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
  end
end