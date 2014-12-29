require "fileutils"
require "optparse"
require "typo_detector/version"

module TypoDetector
  class Command
    def initialize(arguments)
      @options = parse_options(arguments)
      @paths = arguments
    end

    def run
      word_counts = {}
      word_resources = {}
      max_width = 0

      each_files do |path|
        words = nil
        begin
          words = File.read(path).scan(/\w+/)
        rescue
          $stderr.puts("#{$!.message}: <#{path}>")
          next
        end

        words.each do |word|
          word_counts[word] ||= 0
          word_counts[word] += 1
          word_resources[word] = path
        end

        width = words.collect {|word| word.size}.max
        max_width = width if width > max_width
      end

      word_counts.select! do |word, count|
        count == 1
      end

      word_counts.keys.sort_by {|word, count| word_resources[word]}.each do |word|
        puts "#{"%#{max_width}s" % word}: #{word_resources[word]}"
      end
    end

    private
    def parse_options(arguments)
      usage = "Usage: typo_detector [OPTIONS] [FILE]..."
      parser = OptionParser.new(usage)
      parser.version = TypoDetector::VERSION

      options = {}
      parser.on("-g", "--git",
                "Use `git ls-files` with a directory.") do |boolean|
        options[:git] = boolean
      end
      parser.parse!(arguments)

      options
    end

    def each_files
      if @options[:git]
        @paths.each do |path|
          FileUtils.cd(path) do
            `git ls-files`.split(/\n/).each do |path|
              yield(path)
            end
          end
        end
      else
        @paths.each do |path|
          yield(path)
        end
      end
    end
  end
end
