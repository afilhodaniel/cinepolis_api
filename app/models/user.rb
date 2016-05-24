class User < ActiveRecord::Base
  before_create :generate_access_token

  before_save :encrypt_password

  validates :name,     presence: true
  validates :email,    presence: true, uniqueness: true
  validates :password, presence: true, length: 6..12
  
  private

    def encrypt_password
      self.password = Digest::SHA2::hexdigest(password)
    end

    def generate_access_token
      self.access_token = SecureRandom.urlsafe_base64(64, true)
    end

end