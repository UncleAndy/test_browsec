require 'rails_helper'

RSpec.describe ExportService do
  before(:each) do
    @user = FactoryGirl.create(:user)

    @row = FactoryGirl.create(:row, :user_id => @user.id, :name => 'Name', :context => 'Context')
    @phone = FactoryGirl.create(:phone, :row_id => @row.id, :number => '+70000000001')
    @phone2 = FactoryGirl.create(:phone, :row_id => @row.id, :number => '+70000000002')
  end

  describe '.export' do
    it 'должен возвращать правильный CSV' do
      expect(::ExportService.export(@user)).to eq(
"row,#{@row.id},#{@user.id},\"#{@row.name}\",\"#{@row.context}\",#{@row.updated_at_ut}
phone,#{@phone2.id},#{@row.id},\"#{@phone2.number}\",#{@phone.updated_at_ut}
phone,#{@phone.id},#{@row.id},\"#{@phone.number}\",#{@phone.updated_at_ut}
")
    end
  end

  describe '.import' do
    context 'данные того-же пользователя' do
      context 'если данные CSV не актуальны по update_at_ut' do
        context 'идентификация контакта по id' do
          before(:each) do
            @csv = "row,#{@row.id},#{@user.id},\"New CSV row name\",\"New CSV context\",#{DateTime.now.to_i - 1000}
phone,#{@phone.id},#{@row.id},\"1\",#{DateTime.now.to_i - 1000}
phone,#{@phone2.id},#{@row.id},\"2\",#{DateTime.now.to_i - 1000}
"
          end

          it 'не должно добавится новых контактов' do
            expect {
              ::ExportService.import(@csv, @user)
            }.to change(Row, :count).by(0)
          end

          it 'не должно добавится новых телефонов' do
            expect {
              ::ExportService.import(@csv, @user)
            }.to change(Phone, :count).by(0)
          end

          it 'не должны измениться данные' do
            ::ExportService.import(@csv, @user)
            @row.reload
            expect(@row.name).to eq('Name')
            expect(@row.context).to eq('Context')
            @phone.reload
            expect(@phone.number).to eq('+70000000001')
            @phone2.reload
            expect(@phone2.number).to eq('+70000000002')
          end
        end
      end

      context 'изменение и добавление кантакта, добавление и изменение телефона' do
        context 'идентификация контакта по id' do
          before(:each) do
            @csv = "row,#{@row.id},#{@user.id},\"New CSV row name\",\"New CSV context\",#{DateTime.now.to_i + 1000}
phone,#{@phone.id},#{@row.id},\"1\",#{DateTime.now.to_i + 1000}
phone,#{@phone2.id+100},#{@row.id},\"2\",#{DateTime.now.to_i + 1000}
row,#{@row.id+1},#{@user.id},\"New CSV row name 2\",\"New CSV context 2\",#{DateTime.now.to_i + 1000}
phone,#{@phone2.id+200},#{@row.id+1},\"11\",#{DateTime.now.to_i + 1000}
"
          end

          it 'должен добавить 1 контакт' do
            expect {
              ::ExportService.import(@csv, @user)
            }.to change(Row, :count).by(1)
          end

          it 'должен добавить 2 телефона' do
            expect {
              ::ExportService.import(@csv, @user)
            }.to change(Phone, :count).by(2)
          end

          it 'должен поменять данные существующего контакта' do
            ::ExportService.import(@csv, @user)
            @row.reload
            expect(@row.name).to eq('New CSV row name')
            expect(@row.context).to eq('New CSV context')
          end

          it 'должен поменять данные существующего номера' do
            ::ExportService.import(@csv, @user)
            @phone.reload
            expect(@phone.number).to eq('1')
          end
        end

        context 'Идентификация контакта по номеру телефона (id не совпадают)' do
          before(:each) do
            @csv = "row,#{@row.id+100},#{@user.id},\"New CSV row name\",\"New CSV context\",#{DateTime.now.to_i + 1000}
phone,#{@phone.id+100},#{@row.id+100},\"#{@phone.number}\",#{DateTime.now.to_i + 1000}
phone,#{@phone2.id+200},#{@row.id+100},\"2\",#{DateTime.now.to_i + 1000}
"
          end

          it 'не должен добавлять новые контакты' do
            expect {
              ::ExportService.import(@csv, @user)
            }.to change(Row, :count).by(0)
          end

          it 'должен добавить 1 телефон' do
            expect {
              ::ExportService.import(@csv, @user)
            }.to change(Phone, :count).by(1)
          end

          it 'должен изменить данные существующего контакта' do
            ::ExportService.import(@csv, @user)
            @row.reload
            expect(@row.name).to eq('New CSV row name')
            expect(@row.context).to eq('New CSV context')
          end
        end
      end
    end
  end
end
