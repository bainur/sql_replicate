class NcrMapping::ApiResult

  #NcrMapping::ApiResult.ncr_receipt
  def self.ncr_receipt(limit_export = 1000, individual_card = nil)
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
    limit_row = limit_initial(limit_export)
    puts @client
    puts "select TOP #{limit_row} * from HstvbofqAssignment where FKStoreID is not null Order by HstvbofqAssignmentID desc"
    time_execute = Time.now
    conditions = nil
    unless individual_card.blank?
      x = @client.execute("select vbofqMemberAccountID from vbofqMemberAccount where CardNumber = #{individual_card}").each
      member_account_id = x.first["vbofqMemberAccountID"]
      conditions = " AND FKvbofqMemberAccountID = #{member_account_id}"
    end
    results = @client.execute("select TOP #{limit_row} * from HstvbofqAssignment where FKStoreID is not null AND FKStoreID !=0
              #{conditions}
            Order by ActivityDateTime desc").each # do |rs|

    res = []
    results.each do |rs|
      user_id = rs["FKvbofqMemberAccountID"] # this is user id from ncr
      assingnment_id = rs["HstvbofqAssignmentID"]
      merit_amount = @client.execute("select MeritAmount from HstvbofqAssignmentMerit where FKHstvbofqAssignmentID = #{assingnment_id}").each


      balance = @client.execute("select Balance from HstvbofqAdjustment where FKHstvbofqAssignmentID = #{assingnment_id}").each

      card_numbers = @client.execute("select CardNumber from vbofqMemberAccount where vbofqMemberAccountID = #{user_id}").each

      points_holder = []#@client.execute("select FKvbofqRewardProgramID,CommittedMerit from vbofqRewardProgramStandings where FKvbofqMemberAccountID = #{user_id}
#").each

      a = {}
      a = {:card_number => card_numbers.first["CardNumber"], :points_holder => points_holder,
           :merit_amount => (merit_amount.first["MeritAmount"] rescue 0),
           :balance => (balance.first['Balance'] rescue 0)} unless card_numbers.blank?

      ## transaction detail

      @client.execute("select * from HstvbofqCheck inner join gblStore on FKStoreID = StoreId where FKHstvbofqAssignmentID
             = #{assingnment_id} ").each do |detail|
              date_of_business = detail["DateOfBusiness"]
              time_stamp = date_of_business.to_time
              store_id =  detail['SecondaryStoreID']
              status = detail["Status"]
              cashier_id_or_name = detail["FKEmployeeID"].to_s + detail["EmployeeName"].to_s
              subtotal = detail["CheckTotal"]
              receipt_number = detail["CheckNumber"]
      hstv = {
          :date_of_business => date_of_business,
          :store_id => store_id, :status => status,
          :cashier_id_or_name => cashier_id_or_name, :subtotal => subtotal, :receipt_number => receipt_number,
          :time_stamp => time_stamp, :check_id => (detail["HstvbofqCheckID"] rescue nil)
      }
      puts hstv
              puts detail["HstvbofqCheckItemID"]
              items = @client.execute("select HstvbofqCheckItem.*, Item.ShortName, Item.LongName, Item.Price from HstvbofqCheckItem
                inner join Item on Item.ItemId = HstvbofqCheckItem.ItemID
                where
                FKHstvbofqCheckID = #{detail["HstvbofqCheckID"]}").each
              puts items.class
              puts items
      rs.merge!(hstv).merge!(:items => items)
      end

      res << rs.merge!(a)
    end
    #res << "#{Time.now - time_execute}"
    return res.to_json
  end

  def self.limit_initial(limit_export)
    limit = limit_export.blank? ? 1000 : limit_export
    return "#{limit}"
  end

  def self.reward_transaction(limit_export = 1000, params)
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
    limit_row = limit_initial(limit_export)
    card_number = params["card_number"] unless params["card_number"].blank?
    conditions = []
    ## for individual card number
    unless params["card_number"].blank?
      member_account_id = @client.execute("select vbofqMemberAccountID from vbofqMemberAccount where CardNumber = #{params["card_number"]}").each
      member_account_id = member_account_id.first["vbofqMemberAccountID"]

      conditions << " HstvbofqAssignment.FKvbofqMemberAccountID = #{member_account_id}"
    end


    conditions << " FKHstvbofqAssignmentID  =  #{params['assignment_id']}" unless params['assignment_id'].blank?
   # conditions << " Event  =  1 " unless params['assignment_id'].blank?
    conditions << " CheckNumber  =  #{params['check_number']}" unless params['check_number'].blank?
    conditions = conditions.join(" AND ")
    conditions =  conditions if !conditions.include?("AND") and conditions.present?
    limit_row = 10
    puts "a"
    q = ["select TOP #{limit_row} * from HstvbofqAssignmentReward  INNER JOIN HstvbofqAssignment
      ON HstvbofqAssignmentID = HstvbofqAssignmentReward.FKHstvbofqAssignmentID where Proposed = 'true' AND
HstvbofqAssignment.Status = 4 AND RewardAmount <> 0
    "]
    q << conditions unless conditions.blank?
    q = q.join(" AND ") #unless conditions.blank?


    puts q
    result = @client.execute(q).each


    res = []
    result.uniq.each do |rs|
      puts rs
      puts "--------------------------------------------"
      #a = @client.execute("select * from vbofqRewardProgramBonusPlan where FKHstvbofqRewardProgramID = #{rs["FKHstvbofqRewardProgramID"]}").each
      #a = @client.execute("select * from HstvbofqAssignment where HstvbofqAssignmentID = #{rs["FKHstvbofqAssignmentID"]}").each
      # a = @client.execute("select * from vbofqMemberAccount inner join HstvbofqAssignment
      #                      on HstvbofqAssignment.FKvbofqMemberAccountID = vbofqMemberAccountID
      #                      where HstvbofqAssignmentID = #{rs["FKHstvbofqAssignmentID"]}").each
      # reward_name = @client.execute("select *  from vbofqRewardProgram
      # INNER JOIN HstvbofqRewardProgram on FKvbofqRewardProgramID = vbofqRewardProgramID
      # INNER JOIN HstvbofqAssignmentReward ON FKHstvbofqRewardProgramID = HstvbofqRewardProgramID
      # WHERE FKHstvbofqAssignmentID = #{rs['FKHstvbofqAssignmentID']} and Proposed = 'true' and QueueRewards = 'true'").each

#       b = @client.execute(" select * from vbofqRewardProgramTier
#  inner join vbofqRewardProgram on FKHstvbofqRewardProgramID = vbofqRewardProgramID
# where FKvbofqTierID = #{rs['TierID']} and FKHstvbofqRewardProgramID = #{rs['FKHstvbofqRewardProgramID']} ").each
      b = @client.execute(" select * from vbofqRewardProgramBonusPlan
      inner join vbofqBonusPlan on vbofqBonusPlanID = FKvbofqBonusPlanID
      where FKHstvbofqRewardProgramID =  #{rs['FKHstvbofqRewardProgramID']} ").each

      # get card number
      # a = a
      # rs.class

      #reward_name = reward_name.first['RewardProgramName'] rescue nil
      #reward_bpid = reward_name.first['vbofqRewardProgramID'] rescue nil
      reward_name = reward_name
      #res << rs.merge!({:bpid => b.first['FKvbofqBonusPlanID'], :reward_name => b.first['BonusPlanName'], :vbofqBonusPlan => b})
      res << rs.merge!({:bpid => b.first['FKvbofqBonusPlanID'],
                        :reward_name => b.first['BonusPlanName']}).merge!(:cardNumber => card_number)
    end
    return res.first.to_json  unless params['assignment_id'].blank?
    return res.to_json

  end

  def self.get_points(card_number, bpid)
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
    x = @client.execute("select vbofqMemberAccountID from vbofqMemberAccount where CardNumber = #{card_number}").each

    m = @client.execute("select * from vbofqRewardProgramStandings where FKvbofqMemberAccountID = #{x.first['vbofqMemberAccountID']} AND
FKvbofqRewardProgramID  = #{bpid}").each
    return m
  end
end
