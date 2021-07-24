# myapp.rb
require 'sinatra'

# table|key:  value

# def flush
# end

require_relative 'keyvalue'

db = KeyValue.new "demoapp.kv"

get '/' do
  count = db.get("count").to_i
  count += 1
  db.set("count", count)
  #"Hello world! #{count}"
  erb :hello, :locals => {:count => count}
end

