class Level < Sequel::Model
  many_to_one :user

  # Maximum size for uploaded levels.
  MAX_FILE_SIZE = 1024 * 1024 * 20

  # Absolute path to the level file on the hard drive.
  def file_path
    File.join(SmcAddonApp.root, "public", "levelfiles", user.nickname, "#{name}.smclvl")
  end

  # Absolute URI for linking to the level file.
  def file_uri
    "/levelfiles/#{user.nickname}/#{name}.smclvl"
  end

  # Same as #name with underscores replaced with spaces.
  def pretty_name
    name.gsub("_", " ")
  end

  def before_create
    super
    self.uploaded_at = Time.now
  end

  def validate
    super
    return unless new?

    errors.add(:name, "must not be empty") if name.blank?
    errors.add(:name, "has an invalid format") unless name =~ /^[a-zA-Z0-9_]+$/
    errors.add(:description, "must not be empty") if description.blank?
    errors.add(:version, "must not be empty") if version.blank?
    errors.add(:smc_version_requirement, "has an invalid format") unless smc_version_requirement =~ /^[<>=~]{1,2}.*$/
  end
end
