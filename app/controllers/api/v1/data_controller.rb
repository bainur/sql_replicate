class Api::V1::DataController < ApplicationController

  def index

  end

  def ncr_receipt
    row = params[:row].blank? ? 10 : params[:row].to_i
    card_number = params["card_number"]
    date_receipt = params["date"]
    result = NcrMapping::ApiResult.ncr_receipt(row,card_number,date_receipt)

    render :json => result
  end

  def get_points
    card_number = params['card_number']
    bpid = params['bpid']

    res =  NcrMapping::ApiResult.get_points(card_number, bpid)
    render :json => res
  end

  def ncr_reward_transaction
    row = params[:row].blank? ? 10 : params[:row].to_i
    result = NcrMapping::ApiResult.reward_transaction(row, params)
    render :json => result
  end

  def bonus_plans
   res =  NcrMapping::ApiResult.get_bonus_plan(params[:card_number])
   res.each_with_index do |s, index|
    if s["bp_life_time_reward_count"] == 1
      queued_reward = NcrMapping::ApiResult.get_queued_reward(s["member_account_id"], s["bpid"], s["tier_id"])
      # queued_reward_a = {}
      # queued_reward_a["queued_reward"] = queued_reward
      # q = "select top 10 * from HstvbofqAssignment where FKvbofqMemberAccountID = #{s["member_account_id"]}" # AND FKUserID like '%#{s["member_account_id"]}%'"
      # tier = NcrMapping::ApiResult.query(q)
      # queued_reward_a["HstvbofqAssignment"] =tier
      # q = "select top 10 * from HstvbofqAssignmentMerit where FKHstvbofqAssignmentID = 3320525" # AND FKUserID like '%#{s["member_account_id"]}%'"
      # tier = NcrMapping::ApiResult.query(q)
      # queued_reward_a["HstvbofqAssignmentMerit"] =tier
      # q = "select top 10 * from vbofqRewardProgramTier where FKHstvbofqRewardProgramID = 603" # AND FKUserID like '%#{s["member_account_id"]}%'"
      # tier = NcrMapping::ApiResult.query(q)
      # queued_reward_a["vbofqRewardProgramTier"] =tier

      res[index]["queued_reward"] = queued_reward
    end
  end

  render :json => res



end
end
