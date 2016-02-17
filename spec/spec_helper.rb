require 'active_support'
require 'active_support/time'
require 'active_record'
require 'action_controller'
require 'rspec'


# Initialize time_zones from rails
Time.zone = "Berlin"
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'memento'

#ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.establish_connection(:adapter => "mysql2", :database => "memento_test")

# catch AR schema statements
$stdout = StringIO.new

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :projects do |t|
      t.column :name, :string
      t.column :closed_at, :datetime
      t.column :notes, :text
      t.references :customer
      t.integer :ignore_this
      t.timestamps null: false
    end

    create_table :users do |t|
      t.column :email, :string
      t.column :name, :string
      t.timestamps null: false
    end

    create_table :customers do |t|
      t.column :name, :string
      t.timestamps null: false
    end

    create_table :timestampless_objects do |t|
      t.column :name, :string
    end

    create_table :memento_sessions, { :id => false } do |t|
      t.string :id, limit: 32, index: true
      t.string :user_id, limit: 32, index: true
      t.timestamps null: false
      t.string :created_at_ms, limit: 32, index: true
    end
    connection.execute "ALTER TABLE memento_sessions ADD PRIMARY KEY (id);"

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
end

def setup_data
  @user = User.create(:name => "MyUser")
end

def shutdown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class User < ActiveRecord::Base
end unless defined?(User)

class Customer < ActiveRecord::Base
  has_many :projects
end unless defined?(Customer)

class Project < ActiveRecord::Base
  belongs_to :customer

  memento_changes :ignore => :ignore_this
end unless defined?(Project)

class TimestamplessObject < ActiveRecord::Base
  memento_changes
end unless defined?(TimestamplessObject)
