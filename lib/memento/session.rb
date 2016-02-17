module Memento
  class Session < ActiveRecord::Base
    include Replicable
    include Orderable

    self.table_name = "memento_sessions"
    default_scope { order('created_at_ms ASC') }

    has_many :states, -> { order "created_at_ms DESC" },
             :class_name => "Memento::State", :dependent => :delete_all
    belongs_to :user
    has_one :action, :class_name => "Memento::ActionRecord", :dependent => :delete

    # attr_accessible nil

    validates_presence_of :user

    def add_state(action_type, record)
      states.store(action_type, record)
    end

    def undo
      states.map(&:undo).inject(Memento::ResultArray.new) do |results, result|
        result.state.destroy if result.success?
        results << result
      end
    ensure
      destroy if states.count.zero?
    end

    def undo!
      transaction do
        undo.tap do |results|
          raise Memento::ErrorOnRewind if results.failed?
        end
      end
    end
  end
end
