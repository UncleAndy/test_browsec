require 'rails_helper'

RSpec.describe Row, type: :model do
  describe '#random_string' do
    before(:all) do
      @row = Row.new
    end

    it 'должно генерировать значение размером 20 символов (10 hex байтов)' do
      expect(@row.random_string.length).to eq(20)
    end

    it 'должно генерировать для одного экземпляра одно значение' do
      first_string = @row.random_string
      expect(@row.random_string).to eq(first_string)
    end

    it 'должно генерировать для разных экземпляров разные значения' do
      @row2 = Row.new
      first_string = @row2.random_string
      expect(@row.random_string).to_not eq(first_string)
    end
  end
end
