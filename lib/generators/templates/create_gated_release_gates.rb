class CreateGatedReleaseGates < ActiveRecord::Migration
  def change
    create_table :gated_release_gates do |t|
      t.string :name
      t.string :state, default: 'limited'
      t.integer :attempts, default: 0
      t.integer :max_attempts, default: 0
      t.integer :percent_open, default: 0

      t.timestamps
    end
    add_index :gated_release_gates, :name
  end
end
