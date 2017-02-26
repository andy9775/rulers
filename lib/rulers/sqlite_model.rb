require 'sqlite3'
require 'rulers/util'

database_name = ENV['RULERS_ENV'] || 'development.db'
DB = SQLite3::Database.new File.join Dir.pwd, 'db', database_name

module Rulers
  module Model
    class SQLite # :nodoc:
      def initialize(data = nil)
        @hash = data
        # set_accessors
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash['id']
          self.class.create
          true
        end

        fields = @hash.map do |k, v|
          "#{k}=#{self.class.to_sql v}"
        end
                      .join ','

        DB.execute %(
        UPDATE #{self.class.table}
        SET #{fields}
        WHERE id = #{@hash['id']}
        )
        true
      end

      def save
        save!
      rescue
        false
      end

      class << self
        # create a new entry in the table
        def create(values)
          values.stringify_keys
          values.delete 'id'
          keys = schema.keys - ['id']

          vals = keys.map do |key|
            value = values[key] || values[key.to_sym]
            value ? to_sql(value) : 'null'
          end

          DB.execute %(
          INSERT INTO #{table} (#{keys.join ','})
          VALUES (#{vals.join ','});
          )

          data = Hash[keys.zip vals]
          sql = 'SELECT last_insert_rowid();'
          data['id'] = DB.execute(sql)[0][0]

          new data
        end

        def find(id)
          row = DB.execute %(
          SELECT * FROM #{table}
          WHERE id = #{id}
          )
          data = Hash[schema.keys.zip row[0]]
          new data
        end

        def count
          DB.execute(%(
          SELECT COUNT(*) from #{table};
          ))[0][0]
        end

        def schema
          return @schema if @schema
          @schema = {}
          DB.table_info(table) do |row|
            @schema[row['name']] = row['type']
          end
          @schema
        end

        def table
          Rulers.to_underscore name
        end

        def to_sql(val)
          case val
          when Numeric
            val.to_s
          when String
            "'#{val}'"
          else
            raise "Can't change #{val.class} to SQL"
          end
        end
      end

      def method_missing(method, *args, &block)
        if self.class.schema.keys.index method.to_s
          # set the method (accessor) dynamically
          define_singleton_method(method) { @hash[method.to_s] }
          @hash[method.to_s]
        else
          super method, *args, &block
        end
      end

      def respond_to_missing?(method)
        !self.class.schema.keys.index(method.to_s).nil?
      end

      # private

      # set table field accessors
      # def set_accessors
      #   self.class.schema.keys.each do |accessor|
      #     define_singleton_method(accessor) { @hash[accessor] }
      #   end
      # end
    end
  end
end
