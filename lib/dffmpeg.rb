# frozen_string_literal: true

require_relative "dffmpeg/version"
require_relative "dffmpeg/server"
require_relative "dffmpeg/transcode"
require_relative "dffmpeg/worker"

module Dffmpeg
  class Error < StandardError; end
  # Your code goes here...
end
