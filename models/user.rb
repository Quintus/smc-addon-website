class User < Sequel::Model
  one_to_one :registration_token
  one_to_many :levels

  # Return the encrypted password as a BCrypt::Password.
  def password
    BCrypt::Password.new(encrypted_password)
  end

  # Set the user's password to something new. +new_password+
  # is cleartext and will automatically be encrypted.
  #
  # Be sure to call #save after you set this.
  def password=(new_password)
    self.encrypted_password = BCrypt::Password.create(new_password)
  end

  # Match the given cleartext password against the encrypted
  # password storesd in the database. Returns true if they match,
  # false otherwise.
  def authenticate(try_password)
    password == try_password
  end

  # before_create hook.
  def before_create
    super
    self.registered_at = Time.now
  end

  # Execute validatations.
  def validate
    super
    return unless new?

    errors.add(:nickname, "must not be empty") if nickname.blank?
    errors.add(:encrypted_password, "must not be empty") if encrypted_password.blank?
    errors.add(:email, "must not be empty") if email.blank?
    errors.add(:nickname, "is already taken") unless User.where(:nickname => nickname).empty?
    errors.add(:email, "is already taken") unless User.where(:email => email).empty?
    errors.add(:email, "has an invalid format") unless email =~ /^.*?@.*$?/
  end

end
