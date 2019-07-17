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

      # Examples:
      #
      #     scope.full(:module)
      #     scope.full(:prefix)
      #     scope.full(:as)
      #
      def full(option_name)
        items = []
        current = self
        while current

          # puts "scope current: #{option_name} #{current.level}".color(:yellow)
          # pp current

          items.unshift(current.options[option_name]) # <= option_name
          current = current.parent
        end
        items.compact!


        # TODO: REMOVE THIS MESSY DUPLICATION
        # TODO: move this expand_items to be part of the unshift logic above ^^^
        if option_name == :prefix
          if from == :resources
            items = items[0..-2] || []
          elsif from == :resources
            items = expand_items(items)
            items = items[0..-3] || []
          else
            puts "UNSURE IF WE'LL GET HERE"
          end
        end

        if option_name == :module
          if from == :resources
            items = items[0..-2] || [] # works for 1 level nested
            # items = items[0..-3] || [] # works for 2 level nested??
          # elsif resources?
          #   items = expand_items(items)
          #   items = items[0..-3] || []
          end
        end

        return if items.empty?

        if option_name == :as
          items = singularize_leading(items)
          items.join('_')
        else
          items.join('/')
        end
      end

      def full_module
        items = []
        current = self

        i = 0
        while current
          # puts "scope current: module2 #{current.level}".color(:yellow)
          # pp current

          leaf = current.options[:module]
          if leaf
            case current.from
            when :resources
              unless i == 0 # since resources creates an extra layer
                items.unshift(leaf)
              end
            else # namespace or scope
              items.unshift(leaf)
            end
          end

          # puts "items #{items}"

          current = current.parent
          i += 1
        end
        items.compact!

        return if items.empty?

        items.join('/')
      end

      def full_prefix
        items = []
        current = self

        i = 0
        while current
          # puts "scope current: prefix #{current.level}".color(:yellow)
          # pp current

          leaf = current.options[:prefix]
          if leaf
            case current.from
            when :resources
              unless i == 0 # since resources creates an extra layer
                items.unshift(":#{leaf}_id")
                items.unshift(leaf)
              end
            else # namespace or scope
              items.unshift(leaf)
            end
          end

          # puts "items #{items}"

          current = current.parent
          i += 1
        end
        items.compact!

        return if items.empty?

        items.join('/')
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

      def expand_items(items)
        result = []
        items.each do |i|
          result << i
          result << ":#{i.to_s.singularize}_id"
        end
        result
      end

      def from
        @options[:from]
      end
    end
  end
end
