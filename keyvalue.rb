
# A simple keyvalue database.
# Note that flush saves changes,
# by appending to the end of the
# file, and old entries are not removed

class KeyValue
  def initialize(filename="appdata.txt", savemode=:autoflush)
    @filename = filename
    @savemode = savemode
    self.load
    self.save # this rewrites the database without overwritten key entries
  end

  def get(k)
    return @data[k]
  end

  def setfile filename
    @filename = filename
  end

  def set(k, v)
    @data[k] = v
    case @savemode
      when :autoflush
        puts "flushing..."
        self.flush
      when :autosave
        puts "saving..."
        self.save
      else
        @changes[k] = v
    end
  end

  def save
    file = File.new(@filename, "w")
    if file
      @data.each do |key, value|
        s = self.linestring(key, value)
        file.syswrite(s)
      end
    else
      puts "Cannot save data"
    end
  end

  def flush
    file = File.new(@filename, "a+")
    if file
      @changes.each do |key, value|
        s = self.linestring(key, value)
        file.syswrite(s)
      end
      @changes = Hash.new
    else
      puts "Cannot flush data"
    end
  end

  def load
    @data = Hash.new
    @changes = Hash.new
    if not @filename.nil? and File.exist?(@filename)
      File.foreach(@filename) do |line|
        pair = line.split(":", 2)
        @data[pair[0]] = pair[1]
      end
    end
  end

  private

  #TODO escape certain characters like newlines.
  def linestring(key, value)
    return "#{key}: #{value}"
  end
end
