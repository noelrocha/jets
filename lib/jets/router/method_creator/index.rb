class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      join(full_as, path_trunk)
    end

    def meth_args
      items = walk_scope_parents do |current, i, result|
        prefix = current.options[:prefix]
        next unless prefix

        case current.from
        when :resources
          # unless i == 0 because index action doesnt have parameter at the end
          result.unshift(param_name(prefix)) unless i == 0
        else # namespace or scope
          # do nothing
        end
      end

      items.empty? ? nil : "("+items.join(', ')+")"
    end

    def meth_result
      puts "@scope index".color(:cyan)
      pp @scope

      items = walk_scope_parents do |current, i, result|
        prefix = current.options[:prefix]
        next unless prefix

        case current.from
        when :resources
          if i == 0 # index action doesnt have parameter at the end
            result.unshift(prefix)
          else
            param = param_name(prefix)
            result.unshift("#{prefix}/\#{#{param}.to_param}")
          end
        else # namespace or scope
          result.unshift(prefix)
        end
      end

      items.empty? ? nil : '/' + items.join('/')
    end
  end
end
