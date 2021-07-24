
$filename = "data.keyvalue" # csv key value table
$data = Hash.new
$changed = Hash.new
$saveall = 1


def getkv(k)
  return $data[k]
end

def setkv(k, v)
  $data[k] = v
  if $saveall
    savedb
  else
    $changed[k] = true
  end
end

def loaddb
  if File.exist?($filename)
    File.foreach($filename) do |line|
      pair = line.split(":", 2)
      $data[pair[0]] = pair[1]
    end
  else
    initdb
  end
end

def initdb
  $data['count'] = 0
end

def savedb
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


