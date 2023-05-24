# frozen_string_literal: true

require_relative "google_palm_api/version"

module GooglePalmApi
  class Error < StandardError; end
  
  autoload :Client, "google_palm_api/client"
end
