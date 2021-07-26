# myapp.rb
require 'sinatra'

# table|key:  value

# def flush
# end

require_relative 'keyvalue'

db = KeyValue.new({:filename => "demoapp.kv"})
db.exportTables
db.set("a", 5)

get '/' do
  count = db.getTable("stats", "hits", "1").to_i
  count += 1
  db.setTable("stats", "hits", "1", count)
  #"Hello world! #{count}"
  erb :hello, :locals => {:count => count}
end

