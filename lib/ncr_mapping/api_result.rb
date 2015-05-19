class NcrMapping::ApiResult

  #NcrMapping::ApiResult.ncr_receipt
  def self.ncr_receipt(limit_export = 10)
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
    limit_row = limit_initial(limit_export)
    puts @client
    puts "select TOP #{limit_row} * from HstvbofqAssignment where FKStoreID is not null Order by HstvbofqAssignmentID desc"
    results = @client.execute("select TOP #{limit_row} * from HstvbofqAssignment where FKStoreID is not null Order by HstvbofqAssignmentID desc").each # do |rs|

    res = []
    results.each do |x|
      user_id = x["FKvbofqMemberAccountID"] # this is user id from ncr
      card_numbers = @client.execute("select CardNumber from vbofqMemberAccount where vbofqMemberAccountID = #{user_id}").each
      a = {}
      a = {:card_number => card_numbers.first["CardNumber"]} unless card_numbers.blank?
      res << x.merge!(a)
    end

    return results.to_json
  end

  def self.limit_initial(limit_export)
    limit = limit_export.blank? ? 10 : limit_export
    return "#{limit}"
  end
end
