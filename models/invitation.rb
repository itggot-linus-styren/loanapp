class Invitation < ActiveRecord::Base
    has_secure_token
    belongs_to :invited_by, :class_name => "User"
    belongs_to :used_by, :class_name => "User"

    before_create :set_expiration_date
    def set_expiration_date
        self.expiration_date = Time.now + 86400 # 1 day
    end

    scope :claimable, ->{ where("expiration_date > ? AND used_by_id IS NULL", Time.now) }

end