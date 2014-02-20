module Essential
  module Searchable
    extend ActiveSupport::Concern
    @search_columns = []

    def self.add_columns columns
      if columns.kind_of? Array
        columns.each {|column| @search_columns.push(column) unless @search_columns.include? column }
      else
        @search_columns.push columns unless @search_columns.include? columns
      end
    end

    def self.columns
      @search_columns
    end

    module ClassMethods
      def searchable args
        args.each do |key, value|
          Searchable.add_columns value if key == :on or key == :alias
        end
        scoped_search args
      end

      def search params = {}
        params = {} if params.nil?
        Search.new Searchable.columns, params
      end
    end
  end
end
