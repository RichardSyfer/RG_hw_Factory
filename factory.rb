class Factory
  def self.new(*attributes, &block)
    Class.new do
      attr_accessor *attributes

      define_method :initialize do |*args|
        raise 'Error number of arguments' if attributes.count != args.count
        attributes.zip(args).each do |inst_attr, val|
          send("#{inst_attr}=", val)
        end
      end

      define_method :[] do |arg|
        arg.is_a?(Numeric) ? send(attributes[arg]) : send(arg)
      end

      class_eval &block if block_given?

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
        str = ''
        each_pair{ |attr, val| str += " #{attr}=\'#{val}\'" }
        "<factory #{self.class} #{str}>"
      end
      alias_method :inspect, :to_s

      define_method :members do
        attributes
      end

      define_method :size do
        attributes.count
      end
      alias_method :length, :size
    end
  end
end
