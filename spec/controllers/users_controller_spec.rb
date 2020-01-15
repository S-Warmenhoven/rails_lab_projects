require 'rails_helper'

RSpec.describe UsersController, type: :controller do

    describe '#new' do

        it 'should render the new template' do
            get(:new)
            expect(response).to(render_template(:new)) 
        end

        it 'should set an instance variable with a new user' do
            get(:new)
            expect(assigns(:user)).to(be_a_new(User))
        end

    end

    describe '#create' do

        def valid_request
            post(:create, params: { user: FactoryBot.attributes_for(:user) })
        end

        def invalid_request
            post(:create, params: { user: FactoryBot.attributes_for(:user, first_name: nil) })
        end

        context 'with valid parameters' do

            it 'should create a new user in the db' do
                count_before = User.count
                valid_request
                count_after = User.count
                expect(count_after).to eq(count_before + 1)
            end

            it 'should redirect to the home page' do
                valid_request
                expect(response).to(redirect_to root_path)
            end

            it 'should sign the user in' do
                valid_request
                current_user = User.last
                session[:user_id] = current_user.id
                expect(session[:user_id]).to eq(User.last.id)
            end

        end

        context 'with invalid parameters' do

            it 'should assign an invalid user as an instance variable' do
                invalid_request
                expect(assigns(:user)).to be_a(User)
                expect(assigns(:user).valid?).to be(false)
            end
            
            it 'should render the new template' do
                invalid_request
                expect(response).to(render_template(:new))
            end
            
            it 'should not create a user in the db' do
                count_before = User.count
                invalid_request
                count_after = User.count
                expect(count_after).to eq(count_before)
            end

        end

    end

end