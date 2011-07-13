class Search < ActiveRecord::Base
  after_create :assign_permalink

  private
  def assign_permalink
    update_attribute(:permalink, id.to_s(36))
  end
end
