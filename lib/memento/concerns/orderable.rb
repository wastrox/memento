require 'active_support/concern'

module Memento::Orderable
  extend ActiveSupport::Concern

  included do
    before_save :set_created_at_ms
  end

  public

  # generate 32-byte string from Time.now timestamp - used for ordering
  def set_created_at_ms
    self.created_at_ms = ("%.21f" % Time.now.to_f)
  end

end
