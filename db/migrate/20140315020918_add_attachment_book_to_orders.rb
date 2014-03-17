class AddAttachmentBookToOrders < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.attachment :book
    end
  end

  def self.down
    drop_attached_file :orders, :book
  end
end
