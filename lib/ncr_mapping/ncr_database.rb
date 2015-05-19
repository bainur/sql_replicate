class NcrMapping::NcrDatabase
  attr_accessor :client, :result

  def initialize

  end

  def connect_database
    db_setting = SQL_SERVER_DB[Rails.env.to_sym]
    @client = TinyTds::Client.new username: db_setting[:username], password: db_setting[:password], host: db_setting[:host],
                                  database: db_setting[:database]
  end

  def show_data_tables(table_name)
    @result = @client.execute("select * from "+ table_name)
  end

  def close_connection
    @client.close
  end
end