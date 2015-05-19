class Api::V1::DataController < ApplicationController

  def index

  end

  def ncr_receipt
    result = NcrMapping::ApiResult.ncr_receipt

    render :json => result
  end
end