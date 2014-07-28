class RegistrationToken < Sequel::Model
  many_to_one :user

  # List of all possible bytes for tokens. These are
  # 0-9, A-Z, and a-z.
  POSSIBLE_CHARS = ary = (48..57).to_a.concat((65..90).to_a).concat((97..122).to_a).freeze

  def before_create
    super
    self.token = Array.new(16).map { POSSIBLE_CHARS.sample.chr }.join
    self.expires_at = Time.now + 172800 # 2h
  end

end
