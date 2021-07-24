# myapp.rb
require 'sinatra'

# table|key:  value

# def flush
# end

require_relative 'keyvalue'

loaddb

get '/' do
  count = getkv("count").to_i
  count += 1
  setkv("count", count)
  #"Hello world! #{count}"
  erb :hello, :locals => {:count => count}
end

