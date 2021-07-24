
$filename = "data.keyvalue" # csv key value table
$data = Hash.new
$changed = Hash.new
$saveall = 1


def get(k)
  return $data[k]
end

def set(k, v)
  $data[k] = v
  if $saveall
    save
  else
    $changed[k] = true
  end
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


