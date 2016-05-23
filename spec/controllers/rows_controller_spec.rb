require 'rails_helper'

RSpec.describe RowsController, type: :controller do
  render_views

  include Devise::TestHelpers

  before(:each) do
    @user = FactoryGirl.create(:user)
    @user_bad = FactoryGirl.create(:user)

    file = fixture_file_upload('/test.jpg', 'image/jpeg')
    @row = FactoryGirl.create(:row, :user_id => @user.id, :avatar => file, :name => 'Test contact')
    @phone = FactoryGirl.create(:phone, :row_id => @row.id)
    @phone2 = FactoryGirl.create(:phone, :row_id => @row.id)
  end

  context 'Для гостя' do
    describe "#index" do
      it 'должен перенаправлять на страницу логина' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#new" do
      it 'должен перенаправлять на страницу логина' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#create" do
      it 'должен перенаправлять на страницу логина' do
        post :create, { :row => {  :name => 'New row', :context => 'new context' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'должен перенаправлять на страницу логина' do
        get :edit, { :id => @row.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'должен перенаправлять на страницу логина' do
        put :update, { :id => @row.id, :row => {:name => 'Changed row name', :context => 'Changed context'}}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'должен перенаправлять на страницу логина' do
        delete :destroy, { :id => @row.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'Для другого пользователя' do
    before(:each) do
      sign_in @user_bad
    end

    describe '#edit' do
      it 'должен выдавать предупреждение о нехватке прав' do
        get :edit, { :id => @row.id }
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe '#update' do
      it 'должен выдавать предупреждение о нехватке прав' do
        put :update, { :id => @row.id, :row => {:name => 'Changed row name', :context => 'Changed context'}}
        expect(flash[:notice]).to eq(I18n.t('errors.have_not_rights'))
      end
    end

    describe '#destroy' do
      it 'должен выдавать предупреждение о нехватке прав' do
        delete :destroy, { :id => @row.id }
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
        get :index
        expect(response).to be_success
      end

      it 'должен рендерить шаблон index' do
        get :index
        expect(response).to render_template('index')
      end

      it 'должен содержать ссылку для выхода' do
        get :index
        expect(response.body).to include(I18n.t('menu.logout'))
      end

      describe 'поиск' do
        it 'должен возвращать страницу' do
          get :index, :search => 'contact'
          expect(response).to be_success
        end

        it 'должен возвращать на странице верные записи' do
          get :index, :search => 'contact'
          expect(response.body).to include('Test contact')
        end
      end

      describe 'вывод всех записей на странице' do
        it 'должен возвращать страницу' do
          get :index, :size => 'all'
          expect(response).to be_success
        end
      end
    end

    describe "#new" do
      it 'должен возвращать страницу нового контакта' do
        get :new
        expect(response).to be_success
      end
    end

    describe "#create" do
      it 'должен создавать новую запись контакта' do
        expect {
          post :create, { :row => { :name => 'New row', :context => 'new context', :phones => "1\n\2\n3" } }
        }.to change(Row, :count).by(1)
      end

      it 'должен создавать 3 новых записи телефонов' do
        expect {
          post :create, { :row => { :name => 'New row', :context => 'new context', :phones => "1\n\2\n3" } }
        }.to change(Phone, :count).by(3)
      end

      it 'должен делать перенаправление на список контактов' do
        post :create, { :row => {  :name => 'New row', :context => 'new context', :phones => "1\n\2\n3" } }
        expect(response).to redirect_to(rows_path)
      end
    end

    describe '#edit' do
      it 'должен возвращать страницу редактирования' do
        get :edit, { :id => @row.id }
        expect(response).to be_success
      end
    end

    describe '#update' do
      it 'должен менять данные записи' do
        put :update, { :id => @row.id, :row => {:name => 'Changed row name', :context => 'Changed context'}}
        @row.reload
        expect(@row.name).to eq('Changed row name')
        expect(@row.context).to eq('Changed context')
      end

      it 'должен делать перенаправление на список контактов' do
        put :update, { :id => @row.id, :row => {:name => 'Changed row name', :context => 'Changed context'}}
        expect(response).to redirect_to(rows_path)
      end
    end

    describe '#destroy' do
      it 'должен удалять запись' do
        expect {
          delete :destroy, { :id => @row.id }
        }.to change(Row, :count).by(-1)
      end

      it 'должен делать перенаправление на список ссылок' do
        delete :destroy, { :id => @row.id }
        expect(response).to redirect_to(rows_path)
      end
    end

    describe '#export' do
      it 'должен возвращать файл' do
        get :export
        expect(response).to be_success
      end

      it 'должен возвращать файл с правильными данными' do
        get :export
        expect(response.body).to eq(
"row,#{@row.id},#{@user.id},\"#{@row.name}\",\"#{@row.context}\",#{@row.updated_at_ut}
phone,#{@phone2.id},#{@row.id},\"#{@phone2.number}\",#{@phone.updated_at_ut}
phone,#{@phone.id},#{@row.id},\"#{@phone.number}\",#{@phone.updated_at_ut}
")
      end
    end

    describe '#import_form' do
      it 'должен возвращать страницу' do
        get :import_form
        expect(response).to be_success
      end
    end

    describe '#import' do
      before(:each) do
        @csv = fixture_file_upload('/test.csv', 'text/plain')
      end

      it 'должен делать перенаправление на список контактов' do
        post :import, :contacts => @csv
        expect(response).to redirect_to(rows_path)
      end
    end
  end
end
