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

      define_method :[] do |argument|
        argument.is_a?(Numeric) ? send(attributes[argument]) : send(argument)
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
    end
  end
end

# Person = Factory.new(:name, :address) do
#   def about
#     @name
#   end
# end

# p pf = Person.new('Edward', 'LA')
# pf.each_pair { |attr, val| p "#{attr} - #{val}" }
