require 'drb/drb'
require 'streamio-ffmpeg'

module Dffmpeg
  module Worker
    def self.call(uri)
      ts = DRbObject.new_with_uri(uri)
      puts "Worker listening at: #{uri}"
      puts

      loop do
        puts "Ready for tasks..."
        action, input_path = ts.take(['transcode', String])
        movie = FFMPEG::Movie.new(input_path)
        output_path = "#{input_path}.ts"
        movie.transcode(output_path) { |progress| puts progress }
        command = ['transcode-done', input_path, output_path]
        puts "Command: #{command}"
        ts.write(command)
      end
    end
  end
end
