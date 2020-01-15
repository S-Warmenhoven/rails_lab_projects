require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validates" do
    
    it("should require a first_name") do
      user = User.new
      user.valid?
      puts user.errors.messages
      expect(user.errors.messages).to(have_key(:first_name))
    end

    it("should require a last_name") do
      user = User.new
      user.valid?
      expect(user.errors.messages).to(have_key(:last_name))
    end

    it("should require a unique email") do
      persisted_user = FactoryBot.create(:user)
      user = User.new(email: persisted_user.email)
      user.valid?
      expect(user.errors.messages[:email]).to(include('has already been taken'))
    end

    it("full_name method must return first_name and last_name concatenated & titleized") do
      user = FactoryBot.create(:user)
      expect(user.full_name).to eq("#{user.first_name.capitalize} #{user.last_name.titleize}")
    end

  end
end
