class NcrTablesController < ApplicationController

  def index
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client

    if @client.active?
    else
      @result = []
    end
  end

  def show
    @table_name = params[:id]
    a = NcrMapping::NcrDatabase.new
    a.connect_database
    @client = a.client
  end
end