require 'rails_helper'

RSpec.describe NumberService do
  describe '.normalize' do
    it 'должен удалять +7 в начале' do
      expect(::NumberService.normalize('+70000000001')).to eq('0000000001')
    end

    it 'должен удалять 8 в начале' do
      expect(::NumberService.normalize('80000000001')).to eq('0000000001')
    end

    it 'должен удалять все кроме цифр' do
      expect(::NumberService.normalize('+7-000-000-0001kjhkjhkjh')).to eq('0000000001')
    end

    it 'должен удалять все кроме цифр без правильного начала' do
      expect(::NumberService.normalize('jhgjhg000-000-0001kjhkjhkjh')).to eq('0000000001')
    end
  end
end
