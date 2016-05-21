class NumberService
  def self.normalize(number)
    number.gsub(/^(\+7|8)/, '').gsub(/[^\d]+/, '') if number.present?
  end
end
