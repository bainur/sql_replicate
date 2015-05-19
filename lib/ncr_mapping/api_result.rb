class NcrMapping::ApiResult

  #NcrMapping::ApiResult.ncr_receipt
  def self.ncr_receipt(limit_export = 10)
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
    limit_row = limit_initial(limit_export)
    puts @client
    puts "select TOP #{limit_row} * from HstvbofqAssignment where FKStoreID is not null Order by HstvbofqAssignmentID desc"
    results = @client.execute("select TOP #{limit_row} * from HstvbofqAssignment where FKStoreID is not null AND FKStoreID !=0 Order by ActivityDateTime desc").each # do |rs|

    res = []
    results.each do |rs|
      user_id = rs["FKvbofqMemberAccountID"] # this is user id from ncr
      assingnment_id = rs["HstvbofqAssignmentID"]

      card_numbers = @client.execute("select CardNumber from vbofqMemberAccount where vbofqMemberAccountID = #{user_id}").each
      a = {}
      a = {:card_number => card_numbers.first["CardNumber"]} unless card_numbers.blank?

      ## transaction detail

      @client.execute("select * from HstvbofqCheck where FKHstvbofqAssignmentID
             = #{assingnment_id}").each do |detail|
              date_of_business = detail["DateOfBusiness"]
              time_stamp = date_of_business.to_time
              store_id = detail["FKStoreID"]
              status = detail["Status"]
              cashier_id_or_name = detail["FKEmployeeID"].to_s + detail["EmployeeName"].to_s
              subtotal = detail["CheckTotal"]
              receipt_number = detail["CheckNumber"]
      hstv = {
          :date_of_business => date_of_business,
          :store_id => store_id, :status => status,
          :cashier_id_or_name => cashier_id_or_name, :subtotal => subtotal, :receipt_number => receipt_number,
          :time_stamp => time_stamp
      }
      puts hstv
      rs.merge!(hstv)
      end

      res << rs.merge!(a)
    end

    return res.to_json
  end

  def self.limit_initial(limit_export)
    limit = limit_export.blank? ? 10 : limit_export
    return "#{limit}"
  end
end
