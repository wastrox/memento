class MementoMigration < ActiveRecord::Migration

  def self.up
    create_table :memento_sessions, { :id => false } do |t|
      t.string :id, limit: 32, index: true
      t.string :user_id, limit: 32, index: true
      t.timestamps null: false
      t.string :created_at_ms, limit: 32, index: true
    end
    execute "ALTER TABLE memento_sessions ADD PRIMARY KEY (id);"

    create_table :memento_states, { :id => false } do |t|
      t.string :id, limit: 32, index: true
      t.string :action_type
      t.binary :record_data, :limit => 16777215
      t.references :record, :polymorphic => true
      t.references :session
      t.timestamps null: false
      t.string :created_at_ms, limit: 32, index: true
    end
    execute "ALTER TABLE memento_states ADD PRIMARY KEY (id);"

    change_column :memento_states, :record_id, :string, limit: 32, index: true
    change_column :memento_states, :session_id, :string, limit: 32, index: true


    create_table :memento_actions, { :id => false } do |t|
      t.string :id, limit: 32, index: true
      t.string :session_id, limit: 32, index: true
      t.string :action
      t.binary :action_params, :limit => 16777215
    end
    execute "ALTER TABLE memento_actions ADD PRIMARY KEY (id);"

  end

  def self.down
    drop_table :memento_sessions
    drop_table :memento_states
    drop_table :memento_actions
  end

end
