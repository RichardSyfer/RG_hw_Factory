require './factory'

RSpec.describe Factory do
  before(:all) do
    # Person = Factory.new(:name, :address) do
    Person = described_class.new(:name, :address) do
      def about
        @name
      end
    end
  end

  describe 'create class' do
    it 'should have all attribute accessors' do
      accessors = %i{name address}
      expect(Person.instance_methods(false)).to include(*accessors)
    end

    it 'should receive and eval block' do
      expect(Person.instance_methods(false)).to include(:about)
    end
  end

  describe 'create instance' do
    let(:person) { Person.new('Jane Doe', 'LA, Greenwood Sq 223') }

    it 'should create instance of Person cls' do
      expect(person).to be_instance_of Person
    end

    it 'raise error when creating instance with wrong arguments number' do
      expect { Person.new('Jason', 'Timbuktu', 'KT, Street st 209') }
        .to raise_error RuntimeError, 'Error number of arguments'
    end

    it 'getting access to instance attr by [:sym]' do
      expect(person[:name]).to eq 'Jane Doe'
    end

    it 'getting access to instance attr by ["str"]' do
      expect(person['name']).to eq 'Jane Doe'
    end

    it 'posible getting access to instance attr by [0]' do
      expect(person[1]).to eq 'LA, Greenwood Sq 223'
    end
  end
  describe 'instance_methods' do
    let(:person) { Person.new('Jane Doe', 'LA, Greenwood Sq 223') }

    it 'each method return instance_vars values' do
      str = []
      person.each { |x| str << x }
      expect(str).to eq ['Jane Doe', 'LA, Greenwood Sq 223']
    end

    it 'each_pair method return keys and values of instance_vars' do
      str = []
      person.each_pair { |k, v| str << [k, v] }
      expect(str).to eq [[:name, 'Jane Doe'],
                         [:address, 'LA, Greenwood Sq 223']]
    end

    it 'to_s and inspect methods return instance in string form' do
      expect(person.to_s).to eq "<factory Person  name='Jane Doe' address='LA, Greenwood Sq 223'>"
      expect(person.inspect).to eq "<factory Person  name='Jane Doe' address='LA, Greenwood Sq 223'>"
    end

    it 'members method return array of instance_vars' do
      expect(person.members).to eq [:name, :address]
    end

    it 'size and length methods return count of instance_vars' do
      expect(person.size).to eq(2)
      expect(person.length).to eq(2)
    end
  end
end
