class NcrMapping::ReadXls
  def self.external_id(id = nil)
    begin
      restaurant = Spreadsheet.open(Rails.root.to_s + "/test/fixtures/rest_ncr.xls")
      worksheet = restaurant.worksheet(0)
      row = 0
      worksheet.column(8).each_with_index do |cell, index|
        if  cell.to_i == id
          row = index
          break
        end
      end unless id == nil

      row != 0 ? worksheet.row(row)[0].to_i : nil
    rescue
      nil
    end
  end
end