module AuthHelpers
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  private

  def authorized?
    auth.provided? && auth.basic? && credentials_match
  end

  def auth
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
  end

  def credentials_match
    auth.credentials && auth.credentials == [ENV['SLEUTH_USER'], ENV['SLEUTH_PASSWORD']]
  end
end
