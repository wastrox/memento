module Memento
  class ActionRecord < ActiveRecord::Base
    include Replicable

    self.table_name = "memento_actions"
    belongs_to :session, :class_name => "Memento::Session"

    def data
      @action_params ||= Memento.serializer.load(read_attribute(:action_params))
    end

    def data=(data)
      @action_params = nil
      write_attribute(:action_params, data.is_a?(String) ? data : Memento.serializer.dump(data))
    end
  end
end
