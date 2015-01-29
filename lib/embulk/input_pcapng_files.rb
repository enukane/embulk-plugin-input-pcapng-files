require "csv"

module Embulk
  class InputPcapngFiles < InputPlugin
    # input plugin file name must be: embulk/input_<name>.rb
    Plugin.register_input('pcapng_files', self)

    def self.transaction(config, &control)
      task = {
        'paths' => [],
        'done' => config.param('done', :array, default: []),
      }

      task['paths'] = config.param('paths', :array, default: []).map {|path|
        next [] unless Dir.exists?(path)
        Dir.entries(path).sort.select {|entry| entry.match(/^.+\.pcapng$/)}.map {|entry|
          path + "/" + entry
        }
      }.flatten
      task['paths'] = task['paths'] - task['done']

      if task['paths'].empty?
        raise "no valid pcapng file found"
      end

      schema = config.param('schema', :array, default: [])
      columns = []
      columns << Column.new(0, "path", :string)
      idx = 0
      columns.concat schema.map{|c|
        idx += 1
        Column.new(idx, "#{c['name']}", c['type'].to_sym)
      }

      commit_reports = yield(task, columns, task['paths'].length)
      done = commit_reports.map{|hash| hash["done"]}.flatten.compact

      return {"done" => done}
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    attr_reader :task
    attr_reader :schema
    attr_reader :page_builder

    def run
      path = task['paths'][@index]
      each_packet(path, schema[1..-1].map{|elm| elm.name}) do |hash|
        entry = [ path ] + schema[1..-1].map {|c|
          convert(hash[c.name], c.type)
        }
        @page_builder.add(entry)
      end
      @page_builder.finish # must call finish they say

      return {"done" => path}
    end

    private

    def convert val, type
      v = val
      v = "" if val == nil
      v = v.to_i if type == :long
      return v
    end

    def build_options(fields)
      options = ""
      fields.each do |field|
        options += "-e '#{field}' "
      end
      return options
    end

    def each_packet(path, fields, &block)
      options = build_options(fields)
      io = IO.popen("tshark -E separator=, #{options} -T fields -r #{path}")
      while line = io.gets
        array = [fields, CSV.parse(line).flatten].transpose
        yield(Hash[*array.flatten])
      end
      io.close
    end

    def fetch_from_pcap(path, fields)
      options = build_options(fields)
      io = IO.popen("tshark -E separator=, #{options} -T fields -r #{path}")
      data = io.read
      io.close
      return data
    end
  end
end
