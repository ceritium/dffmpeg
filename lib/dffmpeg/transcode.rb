require 'tempfile'
require 'streamio-ffmpeg'
require 'csv'

module Dffmpeg
  class Transcode

    attr_reader :path, :uri, :ts, :segment_list, :tmp_dir, :transcoded_pieces
    def initialize(path, uri)
      @path = path
      @uri = uri
      @segment_list = Tempfile.new
      @tmp_dir = Dir.mktmpdir
    end

    def call
      init_ts
      split
      send_commands
      receive_commands
      join_segments
    end

    def init_ts
      # DRb.start_service
      @ts = DRbObject.new_with_uri(uri)
      puts "Connected to: #{uri}"
    end

    def split
      print "Spliting..."
      # Very small size for testing, it should allow read it from params or
      # calculate it based on the video lenght.
      size = 10
      `ffmpeg -i #{path} -map 0 -c copy -f segment -segment_time #{size} -segment_list #{segment_list.path} -reset_timestamps 1 #{tmp_dir}/%04d.mkv`
    end

    def send_commands
      CSV.read(segment_list.path, headers: [:filename, :from, :to]).each do |row|
        file = File.open(tmp_path(row[:filename]))
        command = ['transcode', tmp_path(row[:filename]), file.read]
        # puts "Sending: #{command}"
        ts.write(command)
      end
    end

    def receive_commands
      @transcoded_pieces = []
      CSV.read(segment_list.path, headers: [:filename, :from, :to]).each do |row|
        command = ['transcode-done', tmp_path(row[:filename]), String]
        puts "Waiting for: #{command}"
        tuple = ts.take(command)
        puts "Received: #{tuple}"
        @transcoded_pieces << tuple[2]
      end
    end

    def join_segments
      output_path = "#{path}.mp4"
      puts "Joining for final file: #{output_path}"

      # It is failing because too many open files
      command = "ffmpeg -y -i 'concat:#{transcoded_pieces.join('|')}' -c copy #{output_path}"
      puts "Running:"
      puts command
      `#{command}`
      print "Done: #{output_path} "
    end

    def tmp_path(filename)
      File.join(tmp_dir, filename)
    end
  end
end
