class Factory
  @kls_name = {}

  def self.new(*attributes, &block)
    raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)' \
          if attributes.length < 1

    cls_name = nil
    cls_name = attributes.shift if attributes.first.is_a?(String)
    if cls_name
      raise NameError, 'class name should to be constant' \
            if cls_name[0] == cls_name.downcase[0]
    end

    self.class.define_method :inspect do
    # define_method :inspect do # for ruby-version < 2.5.x
      if cls_name
        "Factory::#{cls_name}"
      else
        super
      end
    end

    cls = Class.new do
      attr_accessor *attributes # self.send(:attr_accessor, *attributes)

      define_method :initialize do |*args|
        raise ArgumentError,  "wrong number of arguments (given 0," \
                              "expected #{attributes.count})" \
                              if attributes.count != args.count
        attributes.zip(args).each { |inst_attr, val| send("#{inst_attr}=", val) }
      end

      class_eval &block if block_given?

      define_method :[] do |arg|
        arg.is_a?(Numeric) ? send(attributes[arg]) : send(arg)
      end

      define_method :[]= do |key, val|
        key.is_a?(Numeric) ? send("#{attributes[key]}=", val) : send("#{key}=", val)
      end

      define_method :to_a do |*args|
        arr = []
        unless args.empty?
          if args.length == 1
            arr = send(attributes[*args])
          else
            args.each { |arg| arr << send(attributes[arg]) }
          end
        else
          attributes.each { |attr| arr << send(attr) }
        end
        arr
      end
      alias_method :values, :to_a

      define_method :values_at do |*args|
        args.empty? ? [] : values(*args)
      end

      define_method :to_h  do |arg = nil|
        arg ? send(arg) : attributes.zip(self.values).to_h
      end

      define_method :each do |&block|
        attributes.each { |attr| block.call(send(attr)) }
      end

      define_method :each_pair do |&block|
        if block
          attributes.each { |attr| block.call([attr, send(attr)]) }
        else
          self
        end
      end

      define_method :to_s do
        kls_name = "#{ 'Factory::' + cls_name }" if cls_name
        str = ''
        each_pair{ |attr, val| str += " #{attr}=\'#{val}\'" }
        "<factory #{kls_name || self.class}#{str}>"
      end
      alias_method :inspect, :to_s

      define_method :members do
        attributes
      end

      define_method :size do
        attributes.count
      end
      alias_method :length, :size

      define_method :== do |other|
        return true if self.class == other.class && \
                       self.members == other.members && \
                       self.values == other.values
        false
      end

      define_method :eql? do |other|
        return true if self.to_h == other.to_h
        false
      end

      define_method :hash do
        self.values.hash
      end
    end

    if cls_name
      kls = { cls_name.to_sym => cls}
      @kls_name.update(kls)
    end

    return cls
    end

  def Object.const_missing(const)
    @kls_name[const]
  end
end
