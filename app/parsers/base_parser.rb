class BaseParser
  include Rails.application.routes.url_helpers

  def initialize(request)
    @request = request
  end
  
end