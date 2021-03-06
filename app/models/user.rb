require 'openssl'

class User < ApplicationRecord
  ITERATIONS = 20000
  DIGEST = OpenSSL::Digest::SHA256.new
  USERNAME_REGEXP = /\A\w+\z/

  attr_accessor :password

  has_many :questions, :dependent => :destroy

  validates :email, :username, :password, presence: true
  validates :email, :username, uniqueness: true
  validates :password, confirmation: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, format: { with: USERNAME_REGEXP }

  before_validation :downcase_username
  before_save :encrypt_password

  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  def self.authenticate(email, password)
    user = find_by(email: email)
    if user.present? && user.password_hash == User.hash_to_string(OpenSSL::PKCS5.pbkdf2_hmac(password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST))
      user
    else
      nil
    end
  end

  private

  def encrypt_password
    if self.password.present?
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))
      self.password_hash = User.hash_to_string(
        OpenSSL::PKCS5.pbkdf2_hmac(self.password, self.password_salt, ITERATIONS, DIGEST.length, DIGEST)
      )
    end
  end

  def downcase_username
    username&.downcase!
  end
end
