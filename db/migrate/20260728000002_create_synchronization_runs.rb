class CreateSynchronizationRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :synchronization_runs do |t|
      t.string :kind, null: false
      t.string :status, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.integer :duration_ms
      t.integer :processed_games, null: false, default: 0
      t.text :error_message

      t.timestamps
    end

    add_index :synchronization_runs, [:kind, :status, :finished_at],
      name: "index_sync_runs_on_kind_status_finished"
  end
end
