class User < ActiveRecord::Base
  attr_accessor :name, :email, :password, :facebook_id, :facebook_access_token

  before_create :generate_access_token

  before_save :encrypt_password

  validates :name,                  presence: true
  validates :email,                 presence: true, uniqueness: true
  validates :facebook_id,           presence: true, uniqueness: true
  validates :facebook_access_token, presence: true, uniqueness: true

  
  private

    def encrypt_password
      if self.password == nil or self.password.length == 0
        self.password = DateTime.new.to_s
      end

      self.password = Digest::SHA2::hexdigest(password)
    end

    def generate_access_token
      self.access_token = SecureRandom.urlsafe_base64(64, true)
    end

end