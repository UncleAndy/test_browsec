require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
      super resource
    end
  end

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  describe 'После входа пользователя' do
    it 'идет перенаправление на страницу контактов' do
      expect(controller.after_sign_in_path_for(@user)).to eq(rows_path)
    end
  end
end
