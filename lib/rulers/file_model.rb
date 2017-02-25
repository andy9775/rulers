require 'multi_json'

module Rulers
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename

        # get the quote id (unique key)
        basename = File.split(filename)[-1]
        @id = File.basename(basename, '.json').to_i

        obj = File.read filename
        @hash = MultiJson.load obj
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save
        File.open(@filename, 'w') do |f|
          f.write MultiJson.dump(@hash)
        end
      end

      class << self
        def find(id)
          FileModel.new "db/quotes/#{id}.json"
        rescue
          return nil
        end

        def all
          files = Dir['db/quotes/*.json']
          files.map { |f| FileModel.new f }
        end

        def create(attrs)
          hash = {}

          hash['submitter'] = attrs[:submitter] || ''
          hash['quote'] = attrs[:quote] || ''
          hash['attribution'] = attrs[:attribution] || ''

          files = Dir['db/quotes/*.json']
          names = files.map { |f| f.split('/')[-1] }
          highest = names.map(&:to_i).max
          id = highest + 1

          File.open("db/quotes/#{id}.json", 'w') do |f|
            f.write %(
            {
              "submitter": "#{hash['submitter']}",
              "quote": "#{hash['quote']}",
              "attribution": "#{hash['attribution']}"
            }
          )
          end

          FileModel.new "db/quotes/#{id}.json"
        end

        def method_missing(method, *args)
          reg_ex = /^find_all_by_(.*)/.match method
          if reg_ex
            find_by reg_ex[1], args
          else
            raise "#{method} not found"
          end
        end

        def respond_to_missing?(_method_name, _private = false)
          !/^find_all_by_(.*)/.match(method).nil?
        end

        private

        # filter for a list of quotes based on a query parameter
        def find_by(param, query)
          Dir['db/quotes/*.json']
            .map { |f| FileModel.new f }
            .select { |m| !query.index(m[param]).nil? }
        end
      end
    end
  end
end
