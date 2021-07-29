
# A simple keyvalue database.
# Note that flush saves changes,
# by appending to the end of the
# file, and old entries are not removed

class KeyValue
  TableRegex = /<([^\|>]+)\|([^\|>]+)\|([^\|>]+)>/

  def initialize props
    @config = {
      :filename => "appdata.txt",
      :savemode => :autoflush, # savemode :autoflush :autosave or :manual
      :backupmode => :onload, # backupmode :load :manual :1hr :8hr :
      :backups => "backups",
      :tables => "csv",
    }
    self.setConfig props
    self.load
    self.save # rewrite database without overwritten entries
    if @config[:backupmode] == :onload
      self.backup
    end
  end


  def setConfig props
    props.each do |key, value|
      unless key.to_s.strip.empty?
        @config[key] = value
      end
    end
  end

  def get k
    checkKey k
    return @data[k]
  end

  def set k, v
    checkKey k
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

  # TODO keep track of columns
  def getTable(name, column, index)
    if name == "keyvalue"
      raise "keyvalue is a reserved table name"
    end
    if column == "Index"
      raise "Index is a reserved column name"
    end
    key = "<#{name}|#{column}|#{index}>"
    return self.get(key)
  end

  # table names are surrounded by angle brackets
  def setTable(name, column, index, value)
    if name == "keyvalue"
      raise "keyvalue is a reserved table name"
    end
    if column == "Index"
      raise "Index is a reserved column name"
    end
    key = "<#{name}|#{column}|#{index}>"
    #self.
    self.set key, value
  end

  def exportTables
    folder = @config[:tables]
    unless File.directory? folder
      Dir.mkdir folder
    end
    kvfile = File.new(File.join(folder, "keyvalue.csv"), "w")
    if kvfile
      kvfile.syswrite("Key,Value\n")
    else
      raise "Cannot open file."
    end

    # the empty header is the column names.
    tables = Hash.new #table { index => {columns}}
    headers = Hash.new
    
    # puts @data
    @data.each do |key, value|
      result = key.match(TableRegex)
      if result
        tname = result[1]
        column = result[2]
        index = result[3]

        unless tables.has_key? tname
          tables[tname] = Hash.new
          headers[tname] = Hash.new
        end
        table = tables[tname]
        unless table.has_key? index
          table[index] = Hash.new
        end
        table[index][column] = value
        headers[tname][column] = ""
      else
        # write all entries, not in a table, to keyvalue.csv
        unless key.empty?
          kvfile.syswrite("#{key},#{value}\n")
        end
      end
    end
    tables.each do |tname, table|
      path = File.join(folder, tname + ".csv")
      file = File.new(path, "w")

      header = headers[tname]
      headerstr = "Index,"
      cols = header.keys
      puts "cols:", cols
      cols.each { |col| headerstr += "#{col}," }
      if file
        file.syswrite(headerstr.chomp(",") + "\n")
        table.each do |index, data|
          rowstr = "#{index},"
          cols.each { |col| rowstr += data[col] }
          rowstr.chomp(",")
          file.syswrite(rowstr + "\n")
        end
      else
        raise "Cannot open file."
      end
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
          s = linestring(key, value)
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
      Dir.mkdir folder
    end
    time = Time.new
    backupname = time.strftime("%Y%m%d_%H%M-") + @config[:filename]
    path = File.join(folder, backupname)
    self.savepath path
  end

  def flush
    file = File.new(@config[:filename], "a")
    if file
      @changes.each do |key, value|
        unless key.to_s.strip.empty?
          s = linestring(key, value)
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
        unless line.strip.empty?
          pair = line.strip.split(":", 2)
          unless pair[0].strip.empty?
            @data[pair[0].strip] = pair[1].strip
          end
        end
      end
    end
  end

  private

  #TODO escape certain characters like newlines.
  def linestring(key, value)
    return "#{key}:#{value}\n"
  end

  def checkKey key
    if key.include? ":" or key.include? "\n"
      raise "Invalid key, may not contain colons or newlines."
    end
  end
end
