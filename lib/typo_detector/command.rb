require "fileutils"
require "optparse"
require "typo_detector/version"

module TypoDetector
  class Command
    def initialize(arguments)
      @options = parse_options(arguments)
      @paths = arguments
      @word_counts = {}
      @word_resources = {}
      @max_width = 0
      @scan_pattern = scan_pattern
    end

    def run
      index
      filter
      show
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
      parser.on("-_",
                "Split by '_'.") do |boolean|
        options[:_] = boolean
      end
      parser.parse!(arguments)

      options
    end

    def scan_pattern
      if @options[:_]
        /[A-Za-z0-9]+/
      else
        /\w+/
      end
    end

    def index
      each_files do |path, dirname|
        words = nil
        begin
          words = File.read(path).scan(@scan_pattern)
        rescue
          $stderr.puts("#{$!.message}: <#{path}>")
          next
        end

        words.each do |word|
          @word_counts[word] ||= 0
          @word_counts[word] += 1
          if dirname
            @word_resources[word] = File.join(dirname, path)
          else
            @word_resources[word] = path
          end
        end

        width = words.collect {|word| word.size}.max || 0
        @max_width = width if width > @max_width
      end
    end

    def filter
      @word_counts.select! do |word, count|
        count == 1
      end
    end

    def show
      @word_counts.keys.sort.sort_by {|word, count| @word_resources[word]}.each do |word|
        puts "#{"%-#{@max_width}s" % word}: #{@word_resources[word]}"
      end
    end

    def each_files
      if @options[:git]
        @paths.each do |git_dir_path|
          git_dir_basename = File.basename(git_dir_path)
          FileUtils.cd(git_dir_path) do
            `git ls-files`.split(/\n/).each do |path|
              yield(path, git_dir_basename)
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
