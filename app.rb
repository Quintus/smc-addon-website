# -*- coding: utf-8 -*-
require "bundler/setup"
require "logger"
require "fileutils"
Bundler.require :default

class SmcAddonApp < Sinatra::Base

  if ENV["DB_URI"]
    configure(:development){ DB = Sequel.connect(ENV["DB_URI"], :logger => Logger.new($stdout)) }
    configure(:production){ DB = Sequel.connect(ENV["DB_URI"]) }
  else
    $stderr.puts "No DB_URI sepecified. Please set DB_URI to something like sqlite://your_db.db"
    exit 1
  end

  configure :development do
    enable :logging

    # Deliver to mailcatcher in development mode
    Mail.defaults do
      delivery_method :smtp, :address => "localhost", :port => 1025
    end
  end

  configure :production do
    # Use sendmail in production
    Mail.defaults do
      delivery_method :sendmail
    end
  end

  enable :sessions
  set :from_email, "smc-addons@addons.secretmaryo.org"

  use Rack::Flash
  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = SmcAddonApp
  end
  Warden::Manager.serialize_into_session{|user| user.id}
  Warden::Manager.serialize_from_session{|id| User[id.to_i]}

  Warden::Strategies.add(:password) do
    def valid?
      params["nickname"] && params["password"]
    end
    def authenticate!
      u = User.where(:nickname => params["nickname"]).first

      return(fail!("No such user.")) unless u
      return(fail!("Inactive user.")) unless u.activated
      return(fail!("Invalid password.")) unless u.authenticate(params["password"])
      success!(u)
    end
  end

  helpers do
    def markdown(str)
      doc = Kramdown::Document.new(str)
      doc.to_remove_html_tags
      doc.to_html
    end
  end

  get "/" do
    erb :index
  end

  get "/imprint" do
    erb :imprint
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    env["warden"].authenticate!

    flash[:notice] = "Successfully logged in."
    redirect "/"
  end

  get "/unauthenticated" do
    flash[:alert] = "You have to authenticate for this."
    redirect "/login"
  end

  post "/unauthenticated" do
    flash[:alert] = "Invalid username or password."
    redirect "/login"
  end

  get "/logout" do
    env["warden"].logout
    flash[:notice] = "Successfully logged out."
    redirect "/"
  end

  get "/users/new" do
    erb :register
  end

  post "/users/new" do
    begin
      u = User.new
      u.nickname = params["nickname"]
      u.password = params["password"]
      u.email = params["email"]
      u.save
    rescue Sequel::ValidationFailed
      @errors = u.errors
      return erb(:register)
    end

    r = RegistrationToken.create
    u.registration_token = r

    Mail.deliver do
      from SmcAddonApp.from_email
      to u.email
      subject "Confirm your registration"
      body <<-BODY
Hi #{u.nickname},

you registered on addons.secretmaryo.org. Please confirm your registration
by following the link below:

http://addons.secretmaryo.org/users/#{u.nickname}/confirm?token=#{r.token}

The token is valid for 48 hours. If you did not sign up for
addons.secretmaryo.org, please ignore this mail.

--
Automatic message.
      BODY
    end

    flash[:notice] = "Successfully registered. Please check your emails."
    redirect "/"
  end

  get "/users/:nickname/confirm" do
    erb :confirm
  end

  post "/users/:nickname/confirm" do
    u = User.where(:nickname => params["nickname"]).first
    halt 404 unless u
    halt 403 unless params["token"]

    if u.registration_token.token == params["token"]
      u.registration_token.delete
      u.activated = true
      u.save

      flash[:notice] = "Account activated."
      redirect "/login"
    else
      flash[:alert] = "Invalid token."
      redirect "/"
    end
  end

  get "/levels" do
    @levels = Level.all
    erb :levels
  end

  get "/levels/:nickname/:levelname" do
    @level = Level.join(:users, :id => User.filter(:nickname => params["nickname"]).first.id).filter(:name => params["levelname"]).first
    erb :level
  end

  get "/levels/new" do
    halt 401 unless env["warden"].authenticated?

    erb :upload
  end

  post "/levels/new" do
    halt 401 unless env["warden"].authenticated?

    if params["levelfile"][:tempfile].stat.size > Level::MAX_FILE_SIZE
      flash[:alert] = "File to large (max. 20 MiB)."
      return erb(:upload)
    end

    if File.extname(params["levelfile"][:filename]) != ".smclvl"
      flash[:alert] = "Not a .smclvl file."
      return erb(:upload)
    end

    level = Level.new
    level.name = params["name"]
    level.version = params["version"]
    level.smc_version_requirement = params["smc_version_requirement"]
    level.description = params["description"]
    level.user = env["warden"].user
    level.uploaded_at = Time.now

    begin
      level.save
    rescue Sequel::ValidationError
      @errors = level.errors
      return erb(:upload)
    end

    FileUtils.mkdir_p(File.dirname(level.file_path))
    File.open(level.file_path, "wb") do |f| # There may be binary stuff in the scripts
      while chunk = params["levelfile"][:tempfile].read(255) # Don’t blow up on memory
        f.write(chunk)
      end
    end

    logger.info "Wrote '#{level.file_path}'."
    redirect "/levels/#{level.user.nickname}/#{level.name}"
  end

end

require_relative "models/user"
require_relative "models/registration_token"
require_relative "models/level"
