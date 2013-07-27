require "service_now/version"

module ServiceNow
    
    class Incident

        def initialize(attributes = {})
            @attributes = attributes
        end
 
        def method_missing(method, args = nil)
            method_name = method.to_s
            if match = method_name.match(/(.*)=/) # writer method
                attribute = match[1]
                @attributes[attribute] = args
            else # reader method
                @attributes[method_name]
            end
        end
    end
end
