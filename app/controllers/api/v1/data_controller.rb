class Api::V1::DataController < ApplicationController

  def index

  end

  def ncr_receipt
    result = NcrMapping::ApiResult.ncr_receipt

    render :json => result
  end

  def ncr_reward_transaction
    result = NcrMapping::ApiResult.reward_transaction
    render :json => result
  end
end