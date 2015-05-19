class NcrMapping::DataMapping

  attr_accessor :client, :chain_id, :limit_export


  def initialize(chain_id=nil)
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
    @chain_id = chain_id
    @limit_export = limit_export
  end

  #NcrMapping::DataMapping
  #NcrMapping::DataMapping.insert_restaurant
  def insert_restaurant
    # limit_row = " LIMIT #{@limit_export}" unless limit_export.blank?
    # @client.execute("select * from gblStore #{limit_row}").each do |rs|
    #   puts "NcrMapping::DataMapping:: Inserting restaurant : #{rs["name"]}"
    #
    #   # check if restaurant exist
    #   restaurant = Restaurant.where(:name => rs["name"])
    #   if restaurant.blank?
    #     ActiveRecord::Base.connection.execute("INSERT INTO RESTAURANTS
    #       (name, dashboard_display_text, app_display_text, chain_id) values ('#{rs["Name"]}','#{rs["Name"]}','#{rs["Name"]}', #{@chain_id})
    #   ")
    #   end
    # end
  end


  # example
  # a = NcrMapping::DataMapping.new(3);a.insert_receipt
  #

  def insert_receipt
    limit_row = " LIMIT #{@limit_export}" unless limit_export.blank?

    results = @client.execute("select TOP #{@limit_export} * from HstvbofqAssignment where FKStoreID is not null Order by HstvbofqAssignmentID desc").each# do |rs|
    results.each do |rs|
      assingnment_id = rs["HstvbofqAssignmentID"]
      user_id = rs["FKvbofqMemberAccountID"] # this is user id from ncr
      status = rs["Status"]
      created_at = rs["AssignmentDateTime"]
      updated_at = rs["AssignmentDateTime"]

      card_numbers = @client.execute("select CardNumber from vbofqMemberAccount where vbofqMemberAccountID = #{user_id}").each
      ncr_profile = NcrProfile.where("card_number = ?",card_numbers.first["CardNumber"]) unless card_numbers.blank?
      user_id =  ncr_profile.blank?? nil : NcrProfile.user_id

      # if the data exist do nothing
      if NcrReceiptData.where(:assingnment_id => assingnment_id).first.blank? and user_id.present?
        ActiveRecord::Base.connection.execute("INSERT INTO ncr_receipts
        (assingnment_id, chain_id,user_id,status,created_at, updated_at)
        VALUES
        ('#{assingnment_id}', '#{@chain_id}', '#{user_id}','#{status}','#{created_at}', '#{updated_at}' )"
        )


        puts "select * from HstvbofqCheck where FKHstvbofqAssignmentID = #{assingnment_id}"
        res = @client.execute("select * from HstvbofqCheck where FKHstvbofqAssignmentID
 = #{assingnment_id}").each do |rs|
          date_of_business = rs["DateOfBusiness"]
          time_stamp = date_of_business.to_time
          store_id = rs["FKStoreID"]
          status = rs["Status"]
          cashier = rs["FKEmployeeID"].to_s + rs["EmployeeName"].to_s
          subtotal = rs["CheckTotal"]
          receipt_number = rs["CheckNumber"]
          restaurant = Restaurant.where(:ncr_aloha_loyalty_store_id => store_id.to_s).first

          ActiveRecord::Base.connection.execute("INSERT INTO ncr_receipt_transactions
          (issue_date, time_stamp, restaurant_id, cashier,status, subtotal, receipt_number)
          VALUES
(
 '#{date_of_business}','#{time_stamp}','#{restaurant.id}', '#{cashier}', '#{status}','#{subtotal}',
'#{receipt_number}'
)
") unless restaurant.blank?
        end
      end
    end
  end

  def insert_receipt_mash
    limit_row = " LIMIT #{@limit_export}" unless limit_export.blank?

    results = @client.execute("select TOP #{@limit_export} * from HstvbofqAssignment where FKStoreID is not null Order by HstvbofqAssignmentID desc").each# do |rs|
    results.each do |rs|
      assingnment_id = rs["HstvbofqAssignmentID"]
      user_id = rs["FKvbofqMemberAccountID"] # this is user id from ncr
      status = rs["Status"]
      created_at = rs["AssignmentDateTime"]
      updated_at = rs["AssignmentDateTime"]

      card_numbers = @client.execute("select CardNumber from vbofqMemberAccount where vbofqMemberAccountID = #{user_id}").each
      ncr_profile = NcrProfile.where("card_number = ?",card_numbers.first["CardNumber"]) unless card_numbers.blank?
      user_id =  ncr_profile.blank?? nil : NcrProfile.user_id

      # if the data exist do nothing
      if NcrReceiptData.where(:assingnment_id => assingnment_id).first.blank? and user_id.present?
        ActiveRecord::Base.connection.execute("INSERT INTO receipts
        (chain_id,user_id,status,created_at, updated_at)
        VALUES
        ('#{@chain_id}', '#{user_id}','#{status}','#{created_at}', '#{updated_at}' )"
        )


        puts "select * from HstvbofqCheck where FKHstvbofqAssignmentID = #{assingnment_id}"
        res = @client.execute("select * from HstvbofqCheck where FKHstvbofqAssignmentID
 = #{assingnment_id}").each do |rs|
          date_of_business = rs["DateOfBusiness"]
          time_stamp = date_of_business.to_time
          store_id = rs["FKStoreID"]
          status = rs["Status"]
          cashier = rs["FKEmployeeID"].to_s + rs["EmployeeName"].to_s
          subtotal = rs["CheckTotal"]
          receipt_number = rs["CheckNumber"]
          restaurant = Restaurant.where(:ncr_aloha_loyalty_store_id => store_id.to_s).first

          ActiveRecord::Base.connection.execute("INSERT INTO receipt_transactions
          (issue_date, time_stamp, restaurant_id, cashier,status, subtotal, receipt_number)
          VALUES
(
 '#{date_of_business}','#{time_stamp}','#{restaurant.id}', '#{cashier}', '#{status}','#{subtotal}',
'#{receipt_number}'
)
") unless restaurant.blank?
        end
      end
    end
  end

  def search_bpid(program_id)
  # get the tier id
  # FKvbofqTierID
  # FkvBofqBonusPlanID

  # get from vbofqRewardProgramBonusPlan
    @client.execute("select TOP #{1} * from vbofqRewardProgramBonusPlan
    where FKHstvbofqRewardProgramID = #{program_id}").each do |bonus_plan|
       bpid = bonus_plan["FKvbofqBonusPlanID"]
       break unless bpid.blank?
    end
    return bpid
  end


  # example
  # a = NcrMapping::DataMapping.new(3);a.insert_reward_transaction
  #
  def insert_reward_transaction
    limit_row = " LIMIT #{@limit_export}" unless limit_export.blank?
    @client.execute("select TOP #{@limit_export} * from HstvbofqAssignmentReward  INNER JOIN HstvbofqAssignment
      ON HstvbofqAssignmentID = HstvbofqAssignmentReward.FKHstvbofqAssignmentID where Proposed ='true' AND QueueRewards = 'true'").each do |rs|

      assingment_date_time = rs["AssignmentDateTime"]
      activity_datetime = rs["ActivityDateTime"]
      program_id = rs["FKHstvbofqRewardProgramID"]
      store_id = rs['FKStoreID']

      reward_relevant = Reward.where(:bpid => program_id).first
      reward_id = reward_relevant.id unless reward_relevant.blank?
      restaurant_id = Restaurant.where(:ncr_aloha_loyalty_store_id => store_id.to_s).first


      ## insert the count of the reward summaries
      unless restaurant_id.blank? and reward_id.blank?
        # update the summary
        rsum = RewardSummary.where("transaction_date = date('#{assingment_date_time}') and restaurant_id = ?", restaurant_id.id).first
        if rsum.blank?
          RewardSummary.create(:transaction_date => assingment_date_time.to_date,
                               :total => 1, :restaurant_id => restaurant_id.id, :chain_id => @chain_id)
        else
          rsum.update_attribute(:total, rsum.total + 1)
        end

        ## insert the detail here
        ActiveRecord::Base.connection.execute("
    INSERT INTO reward_transaction_ncrs
            (activity_datetime,assignment_datetime, code, reward_id, chain_id, restaurant_id, created_at, updated_at)
    VALUES
            ('#{activity_datetime}','#{assingment_date_time}','',
'#{reward_id}','#{@chain_id}','#{restaurant_id.id}', '#{Time.now}', '#{Time.now}')
    ")
      end
    end
  end

  def insert_reward_transaction_mash
    
  end
end