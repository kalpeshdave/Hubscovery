class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :q
      t.string :permalink

      t.timestamps
    end

    add_index :searches, :permalink, :unique => true
  end

  def self.down
    drop_table :searches
  end
end
