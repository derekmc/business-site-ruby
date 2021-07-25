
# A simple keyvalue database.
# Note that flush saves changes,
# by appending to the end of the
# file, and old entries are not removed

class KeyValue

  def initialize props
    @config = {
      :filename => "appdata.txt",
      :savemode => "autoflush", # savemode :autoflush :autosave or :manual
      :backupmode => "load", # backupmode :load :manual :1hr :8hr :
      :backups => "backups",
    }
    self.setConfig props
    self.load
    self.save # rewrite database without overwritten entries
  end

  def get(k)
    return @data[k]
  end

  def setConfig props
    props.each do |key, value|
      unless key.to_s.strip.empty?
        @config[key] = value
      end
    end
  end

  def setfile filename
    @config[:filename] = filename
  end

  def set(k, v)
    @data[k] = v
    @changes[k] = v
    savemode = @config[:savemode]
    case savemode
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
    self.savepath @config[:filename]
  end

  def savepath path
    file = File.new(path, "w")
    if file
      @data.each do |key, value|
        unless key.to_s.strip.empty?
          s = self.linestring(key, value)
          file.syswrite(s)
        end
      end
      @changes = Hash.new
    else
      puts "Cannot save data"
    end
  end

  def backup
    folder = @config[:backups]
    unless File.directory? folder
      File.mkdir folder
    end
    backupname = time.strftime("%Y%m%d_%H%M-") + @config[:filename]
    path = File.join(folder, backupname)
    self.savepath path
  end

  def flush
    file = File.new(@config[:filename], "a")
    if file
      @changes.each do |key, value|
        unless key.to_s.strip.empty?
          s = self.linestring(key, value)
          file.syswrite(s)
        end
      end
      @changes = Hash.new
    else
      puts "Cannot flush data"
    end
  end

  def load
    @data = Hash.new
    @changes = Hash.new
    filename = @config[:filename]
    if not filename.nil? and File.exist?(filename)
      File.foreach(filename) do |line|
        unless line.empty?
          pair = line.split(":", 2)
          @data[pair[0]] = pair[1]
        end
      end
    end
  end

  private

  #TODO escape certain characters like newlines.
  def linestring(key, value)
    return "#{key}: #{value}\n"
  end
end
