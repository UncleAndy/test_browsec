require 'rails_helper'

RSpec.describe PhonesController, type: :controller do
  render_views

  include Devise::TestHelpers

  before(:each) do
    @user = FactoryGirl.create(:user)
    @user_bad = FactoryGirl.create(:user)

    file = fixture_file_upload('/test.jpg', 'image/jpeg')
    @row = FactoryGirl.create(:row, :user_id => @user.id, :avatar => file)
    @phone = FactoryGirl.create(:phone, :row_id => @row.id)
    @phone2 = FactoryGirl.create(:phone, :row_id => @row.id)
  end

  context 'Для гостя' do
    describe "#index" do
      it 'должен перенаправлять на страницу логина' do
        get :index, :row_id => @row.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#new" do
      it 'должен перенаправлять на страницу логина' do
        get :new, :row_id => @row.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#create" do
      it 'должен перенаправлять на страницу логина' do
        post :create, { :row_id => @row.id, :phone => {  :number => '1' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'должен перенаправлять на страницу логина' do
        get :edit, { :row_id => @row.id, :id => @phone.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'должен перенаправлять на страницу логина' do
        put :update, { :row_id => @row.id, :id => @phone.id, :phone => {:number => '1'}}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'должен перенаправлять на страницу логина' do
        delete :destroy, { :row_id => @row.id, :id => @phone.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'Для другого пользователя' do
    before(:each) do
      sign_in @user_bad
    end

    describe "#index" do
      it 'должен выдавать предупреждение о нехватке прав' do
        get :index, :row_id => @row.id
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe "#new" do
      it 'должен выдавать предупреждение о нехватке прав' do
        get :new, :row_id => @row.id
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe "#create" do
      it 'должен выдавать предупреждение о нехватке прав' do
        post :create, {:row_id => @row.id, :phone => { :number => '1' } }
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe '#edit' do
      it 'должен выдавать предупреждение о нехватке прав' do
        get :edit, { :row_id => @row.id, :id => @phone.id }
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe '#update' do
      it 'должен выдавать предупреждение о нехватке прав' do
        put :update, { :row_id => @row.id, :id => @phone.id, :phone => {:number => '1'}}
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe '#destroy' do
      it 'должен выдавать предупреждение о нехватке прав' do
        delete :destroy, { :row_id => @row.id, :id => @phone.id }
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end
  end

  context 'Для залогиненного пользователя' do
    before(:each) do
      sign_in @user
    end

    describe "#index" do
      it 'должен возвращать страницу' do
        get :index, :row_id => @row.id
        expect(response).to be_success
      end

      it 'должен рендерить шаблон index' do
        get :index, :row_id => @row.id
        expect(response).to render_template('index')
      end

      it 'должен содержать ссылку для выхода' do
        get :index, :row_id => @row.id
        expect(response.body).to include(I18n.t('menu.logout'))
      end
    end

    describe "#new" do
      it 'должен возвращать страницу нового контакта' do
        get :new, :row_id => @row.id
        expect(response).to be_success
      end
    end

    describe "#create" do
      it 'должен создавать новую запись контакта' do
        expect {
          post :create, { :row_id => @row.id, :phone => { :number => '1' } }
        }.to change(Phone, :count).by(1)
      end

      it 'должен делать перенаправление на список контактов' do
        post :create, { :row_id => @row.id, :phone => { :number => '1' } }
        expect(response).to redirect_to(row_phones_path(@row.id))
      end
    end

    describe '#edit' do
      it 'должен возвращать страницу редактирования' do
        get :edit, { :row_id => @row.id, :id => @phone.id }
        expect(response).to be_success
      end
    end

    describe '#update' do
      it 'должен менять данные записи' do
        put :update, { :row_id => @row.id, :id => @phone.id, :phone => { :number => '2' }}
        @phone.reload
        expect(@phone.number).to eq('2')
      end

      it 'должен делать перенаправление на список контактов' do
        put :update, { :row_id => @row.id, :id => @phone.id, :phone => { :number => '2' }}
        expect(response).to redirect_to(row_phones_path(@row.id))
      end
    end

    describe '#destroy' do
      it 'должен удалять запись' do
        expect {
          delete :destroy, { :row_id => @row.id, :id => @phone.id }
        }.to change(Phone, :count).by(-1)
      end

      it 'должен делать перенаправление на список ссылок' do
        delete :destroy, { :row_id => @row.id, :id => @phone.id }
        expect(response).to redirect_to(row_phones_path(@row.id))
      end
    end
  end
end
