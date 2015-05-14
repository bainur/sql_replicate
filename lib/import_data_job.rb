class NcrMapping::ImportDataJob < Struct.new(:chain_id, :row_limit)
  def perform
    NcrDataReceipt.delete_all
    NcrReceiptTransaction.delete_all
    RewardTransactionNcr.delete_all
    a = NcrMapping::DataMapping.new(chain_id)
    a.limit_export = row_limit
    a.insert_receipt
    a.insert_reward_transaction
  end
end