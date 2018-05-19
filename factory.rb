class Factory
  include Enumerable

  def self.new(*attributes, &block)
    if attributes.empty?
      raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)'
    end

    subclass_name = attributes.shift if attributes.first.is_a?(String)
    if subclass_name
      if subclass_name[0] == subclass_name.downcase[0]
        raise NameError, 'class name should to be constant'
      end
    end

    cls = Class.new self do
      attr_accessor *attributes # self.send(:attr_accessor, *attributes)

      define_singleton_method :new do |*args, &blck|
        instance = allocate
        instance.send(:initialize, *args, &blck)
        instance
      end

      define_method :initialize do |*args|
        if attributes.count != args.count
          raise ArgumentError,
            "wrong number of arguments (given 0, expected #{attributes.count})"
        else
          attributes.zip(args).each { |inst_attr, val| send("#{inst_attr}=", val) }
        end
      end

      class_eval &block if block_given?
    end

    subclass_name ? const_set(subclass_name, cls) : cls
  end

  def members
    instance_variables.map { |inst_var| :"#{inst_var.to_s.sub(/[@]/, '')}" }
  end

  def [](arg)
    if arg.is_a?(Numeric)
      check_index_range(arg)
      send(members[arg])
    else
      send(arg)
    end
  end

  def []=(key, val)
    if key.is_a?(Numeric)
      check_index_range(key)
      send("#{members[key]}=", val)
    else
      send("#{key}=", val)
    end
  end

  def to_a(*args)
    arr = []
    if args.empty?
      members.each { |attr| arr << send(attr) }
    else
      args.each { |arg| arr << send(members[arg]) }
    end
    arr
  end
  alias values to_a

  def values_at(*args)
    check_index_range(args)
    args.count == 1 ? send(members[*args]) : values(*args)
  end

  def to_h(arg = nil)
    arg ? send(arg) : members.zip(values).to_h
  end

  def each(&block)
    block ? members.each { |attr| yield(send(attr)) } : to_enum
  end

  def each_pair(&block)
    block ? members.each { |attr| yield([attr, send(attr)]) } : to_enum
  end

  def select(&block)
    block ? values.select(&block) : to_enum
  end

  def dig(*args)
    to_h.dig(*args)
  end

  def to_s
    str = ''
    each_pair { |attr, val| str += " #{attr}=\'#{val}\'" }
    "<factory #{self.class}#{str}>"
  end
  alias inspect to_s

  def size
    members.count
  end
  alias length size

  def ==(other)
    self.class == other.class &&
      self.members == other.members &&
      self.values == other.values
  end

  def eql?(other)
    self.to_h == other.to_h
  end

  def hash
    values.hash
  end

  private

  def check_index_range(indx)
    indx = [indx] if indx.is_a?(Numeric)
    indx.each do |index|
      raise IndexError, "wrong index range" if (index < -size) || (index >= size)
    end
    true
  end
end
