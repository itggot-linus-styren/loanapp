class User < ActiveRecord::Base

    before_create :set_date_to_now
    def set_date_to_now
        self.registred_at = Time.now
    end

    scope :for_user_type, ->(type){ where("user_type = ?", type) }
    
    scope :find_by_username_nocase, ->(username){ where("LOWER(username) = ?", username.downcase) }

end