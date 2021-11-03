require 'rinda/tuplespace'
module Dffmpeg
  module Server
    def self.call(uri = "druby://localhost:12345")
      $ts = Rinda::TupleSpace.new
      DRb.start_service(uri, $ts)
      puts "Dffmpeg server listening at: #{DRb.uri}"

      DRb.thread.join
    end
  end
end
