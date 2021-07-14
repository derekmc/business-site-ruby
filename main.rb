# myapp.rb
require 'sinatra'

# table|key:  value

$filename = "data.keyvalue" # csv key value table
$data = Hash.new
$changed = []



def get(k)
  return $data[k]
end

def set(k, v)
  $data[k] = v
end

def load
  if File.exist?($filename)
    File.foreach($filename) do |line|
      pair = line.split(":", 2)
      $data[pair[0]] = pair[1]
    end
  else
    initdata
  end
end

def initdata
  $data['count'] = 0
end

def save
  file = File.new($filename, "w")
  if file
    $data.each do |key, value|
      x = file.syswrite("#{key}: #{value}")
      puts x
    end
  else
    puts "Cannot save data"
  end
end

# def flush
# end

load

get '/' do
  count = get("count").to_i
  count += 1
  set "count", count
  save
  "Hello world! #{count}"
end

