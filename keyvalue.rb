
class KeyValue
  def initialize(filename="appdata.txt", saveall=1)
    @filename = filename
    @saveall = saveall
    self.load
  end

  def get(k)
    return @data[k]
  end

  def setfile filename
    @filename = filename
  end

  def set(k, v)
    @data[k] = v
    if @saveall
      save
    end
  end

  def save
    file = File.new(@filename, "w")
    if file
      @data.each do |key, value|
        x = file.syswrite("#{key}: #{value}")
        puts x
      end
    else
      puts "Cannot save data"
    end
  end


  def load
    @data = Hash.new
    @changed = Hash.new
    if !@filname.nil? and File.exist?(@filename)
      File.foreach(@filename) do |line|
        pair = line.split(":", 2)
        @data[pair[0]] = pair[1]
      end
    end
  end
end


=begin
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

=end
