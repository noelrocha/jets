module Jets
  class Router
    class Scope
      include Util

      attr_reader :options, :parent, :level
      def initialize(options = {}, parent = nil, level = 1)
        @options = options
        @parent = parent
        @level = level
      end

      def root?
        @parent.nil?
      end

      def new(options={})
        self.class.new(options, self, level + 1)
      end

      def full_module
        items = walk_parents do |current, i, result|
          mod = current.options[:module]
          next unless mod

          case current.from
          when :resources, :resource
            unless i == 0 # since resources and resource create an extra 'scope' layer
              result.unshift(mod)
            end
          else # namespace or scope
            result.unshift(mod)
          end
        end

        items.compact!
        items.empty? ? nil : items.join('/')
      end

      def full_prefix
        items = walk_parents do |current, i, result|
          # puts "current.level #{current.level}:".color(:green)
          # pp current.options

          prefix = current.options[:prefix]
          next unless prefix

          case current.from
          when :resources
            variable = prefix.to_s.split('/').last
            variable = ":#{variable.singularize}_id"
            result.unshift(variable)
            result.unshift(prefix)
          else # namespace or scope
            result.unshift(prefix)
          end
        end

        items.compact!
        items.empty? ? nil : items.join('/')
      end

      def full_as
        items = []
        current = self
        while current
          items.unshift(current.options[:as]) # <= option_name
          current = current.parent
        end

        items.compact!
        return if items.empty?

        items = singularize_leading(items)
        items.join('_')
      end

      def walk_parents
        current, i, result = self, 0, []
        while current
          yield(current, i, result)
          current = current.parent
          i += 1
        end
        result
      end

      # singularize all except last item
      def singularize_leading(items)
        result = []
        items.each_with_index do |item, index|
          item = item.to_s
          r = index == items.size - 1 ? item : item.singularize
          result << r
        end
        result
      end

      def from
        @options[:from]
      end
    end
  end
end
