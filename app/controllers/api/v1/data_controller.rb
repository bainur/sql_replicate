class Api::V1::DataController < ApplicationController

  def index

  end

  def ncr_receipt
    row = params[:row].blank? ? 10 : params[:row].to_i
    card_number = params["card_number"]
    result = NcrMapping::ApiResult.ncr_receipt(row,card_number)

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
end