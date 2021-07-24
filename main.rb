# myapp.rb
require 'sinatra'

# table|key:  value

# def flush
# end

require_relative 'keyvalue'

load

get '/' do
  count = get("count").to_i
  count += 1
  set("count", count)
  "Hello world! #{count}"
end

