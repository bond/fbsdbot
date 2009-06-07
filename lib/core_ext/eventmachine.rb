require 'time'
module EventMachine
  def self.daily at, &blk
    time = Time.parse(at) - Time.now
    time += 1.day if time < 0

    EM.run do
      run_me = proc{
        EM.add_timer(1.day, run_me)
        blk.call
      }
      EM.add_timer(time, run_me)
    end
  end
end