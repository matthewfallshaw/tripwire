require 'optparse'
require 'tripwire/runner'

module Tripwire
  class CLI
    
    def initialize(args)
      scanner = Tripwire::Scanner.new
      recursive = true
      delay = 1
      option_parser = OptionParser.new do |opt|
        opt.banner = "Usage: tripwire [options] <command> <filespec>+"
        opt.on("-e","--exclude <pattern>", String, "a pattern defining files/folders to ignore") do |e|
          scanner.exclude_patterns << e
        end
        opt.on("-d","--delay <seconds>", Integer, "number of seconds between each scan (defaults to 1)") do |d|
          delay = d
        end
        opt.on("-v","--verbose", "outputs changes as they are discovered") do
          scanner.verbose = true
        end
        opt.on("-n","--non-recursive", "tells tripwire *not* to scan folders recursively") do
          recursive = false
        end
      end

      option_parser.parse!(args)
            
      command = args.shift
      args.map!{|arg| File.directory?(arg) ? "#{arg}/**/*" : arg} if recursive
      scanner.scan_patterns.concat(args)
      runner = Tripwire::Runner.new(scanner, command, :delay => delay)
      runner.run! rescue puts "#{$!}\n(type tripwire -h for help)"
      
    end
    
  end
end