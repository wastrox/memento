require 'active_support/concern'

module Memento::Replicable
  extend ActiveSupport::Concern

  included do
    before_create :generate_uuid
  end

  public

  def generate_uuid
    if self.id.to_s == "" || self.class.exists?(id: self.id) # if no id specified or id exists in db, then generate new id
      begin
        self.id = new_uuid
      end while self.class.exists?(id: self.id)
    end
    return self.id
  end

  def new_uuid
    SecureRandom.uuid.gsub('-','')
  end

end
