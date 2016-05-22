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

  # Возможные кейсы с данными контактов:
  # - если пользователь не соответствует текущему:
  #   - для каждого контакта производится его идентификация по имеющимся в базе номерам;
  # - если пользователь тот-же:
  #   - обновление данных контактов и телефонов производится только если время новых данных больше;
  #   - удаление номеров НЕ производится
  def self.import(csv, current_user)
    # Парсинг данных
    rows = parse_csv(csv)

    # Анализ данных

    # Цикл по контактам
    rows.keys.each do |row_id|
      # Идентифицируем контакт
      row = rows[row_id]
      db_row = if row[:user_id] == current_user.id
                 # Ищем контакт по id
                 Row.find_by_id(row[:id])
               end

      Rails.logger.info("DBG: Row founded by id") if db_row.present?

      if db_row.blank?
        # Если другой пользователь или такого контакта нет - ищем по нормализованному номеру телефона
        # До первого совпадения
        Rails.logger.info("DBG: Find row by phone number")
        row[:phones].keys.each do |phone_id|
          phone = row[:phones][phone_id]
          db_phone = Phone.find_by_normalized(phone[:normalized])
          db_row = db_phone.row if db_phone.present?
          break if db_row.present?
        end
        Rails.logger.info("DBG: Row founded by phone number") if db_row.present?
      end

      if db_row.present?
        # Контакт найден - синхронизируем
        if db_row.updated_at_ut < row[:updated_at_ut]
          # Если данные контакта в базе более поздние - обновляем их
          Rails.logger.info("DBG: Imported data news - update db row")
          db_row.update_columns(:name => row[:name], :context => row[:context])
        end

        # Синхронизируем телефоны
        row[:phones].keys.each do |phone_id|
          phone = row[:phones][phone_id]

          Rails.logger.info("DBG: Sync phone #{phone[:number]}...")

          db_phone = nil
          if row[:user_id] == current_user.id
            # Если юзер этот-же - сначала проверяем изменение по phone_id
            db_phone = db_row.phones.find_by_id(phone_id)

            Rails.logger.info("DBG: Found number #{phone[:number]} by id (#{phone_id})") if db_phone.present?

            # Изменяем номер телефона если он найден, значение другое и время изменения в базе раньше чем в CSV
            if db_phone.present? && db_phone.number != phone[:number] && db_phone.updated_at_ut < phone[:updated_at_ut]
              Rails.logger.info("DBG: Upate number #{phone[:number]}")
              db_phone.update(:number => phone[:number])
            end
          end

          if db_phone.blank?
            # Если юзер другой или номера не существует - проверяем существует-ли такой номер и добавлем если его нет
            db_phone = db_row.phones.find_by_normalized(phone[:normalized])

            Rails.logger.info("DBG: Found number #{phone[:number]} by number") if db_phone.present?

            # Добавляем новый телефон если его нет в базе
            if db_phone.blank?
              Rails.logger.info("DBG: Add number #{phone[:number]}")
              db_row.phones.create(:number => phone[:number])
            end
          end
        end
      else
        # Контакт не найден - создаем новый
        Rails.logger.info("DBG: Add new row")
        db_row = current_user.rows.create(:name => row[:name], :context => row[:context])

        # Если по какой-то причине контакт не создался - игнорируем
        if db_row.present?
          # Добавляем телефоны в новый контакт
          row[:phones].keys.each do |phone_id|
            phone = row[:phones][phone_id]
            Rails.logger.info("DBG: Add new number #{phone[:number]}")
            db_row.phones.create(:number => phone[:number])
          end
        end
      end
    end
  end

  private

  def self.parse_csv(csv)
    # Контакты из импортируемого файла
    new_rows = {}

    CSV.parse(csv, :headers => false, :col_sep => ',', :quote_char => '"') do |line|
      if line[0] == 'row'
        # Используется поатрибутное присвоение для случая если телефоны идут раньше контакта
        id = line[1].to_i
        new_rows[id] = {} if new_rows[id].blank?
        new_rows[id][:id] = id
        new_rows[id][:user_id] = line[2].to_i
        new_rows[id][:name] = line[3]
        new_rows[id][:context] = line[4]
        new_rows[id][:updated_at_ut] = line[5].to_i
      elsif line[0] == 'phone'
        phone = {
            id: line[1].to_i,
            row_id: line[2].to_i,
            number: line[3],
            updated_at_ut: line[4].to_i,
            normalized: ::NumberService.normalize(line[3])
        }

        new_rows[phone[:row_id]] = {} if new_rows[phone[:row_id]].blank?
        new_rows[phone[:row_id]][:phones] = {} if new_rows[phone[:row_id]][:phones].blank?
        new_rows[phone[:row_id]][:phones][phone[:id]] = phone
      end
    end

    new_rows
  end
end
