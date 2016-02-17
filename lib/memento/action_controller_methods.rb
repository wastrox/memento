module Memento
  module ActionControllerMethods

    def memento(action_record_options={})
      block_result = nil
      memento_session = Memento(current_user) do
        block_result = yield
      end

      if memento_session
        response.headers["X-Memento-Session-Id"] = memento_session.id.to_s

        if action_record_options.size>0 # create action record only if we got options
          if action_record_options[:action] && action_record_options[:params] # make sure we got correct options (at least not blank)
            r = Memento::ActionRecord.new
            r.action = action_record_options[:action]
            r.action_params=action_record_options[:params]
            r.session_id = memento_session.id
            r.save
          end
        end

      end
      block_result
    end
    private :memento
  end
end

ActionController::Base.send(:include, Memento::ActionControllerMethods) if defined?(ActionController::Base)
