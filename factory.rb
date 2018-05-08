class Factory
  def self.new(*attributes, &block)
    Class.new do
      attr_accessor *attributes

      define_method :initialize do |*args|
        fail 'Error number of arguments' if attributes.count != args.count
        attributes.zip(args).each do |inst_attr, val|
          send("#{inst_attr}=", val)
        end
      end

      define_method :[] do |argument|
        argument.is_a?(Numeric) ? send(attributes[argument]) : send(argument)
      end

      class_eval &block if block_given?
    end
  end
end

# Person = Factory.new(:name, :address) do
#   def print
#     @name.to_s
#   end
# end

# p pf = Person.new('Edward', 'LA', '1')
# p pf.print
# p pf.class