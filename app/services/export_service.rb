require 'csv'

class ExportService
  def self.export(user)
    attrs = %w(id user_id name context updated_at_ut)

    csv = ''
    user.rows.each do |row|
      csv = "#{csv}row,#{row.id},#{row.user_id},\"#{row.name}\",\"#{row.context}\",#{row.updated_at_ut}\n"
      row.phones.each do |phone|
        csv = "#{csv}phone,#{phone.id},#{row.id},\"#{phone.number}\",#{phone.updated_at_ut}\n"
      end
    end
    csv
  end
end
