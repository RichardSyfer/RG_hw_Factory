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

    it 'should create instance of Factory::MyCls' do
      Factory.new('MyCls', :name)
      my_cls = Factory::MyCls.new('Instance Name')
      expect(my_cls).to be_instance_of Factory::MyCls
    end

    it 'raise error when creating instance with wrong arguments number' do
      expect { Person.new('Jason', 'Timbuktu', 'KT, Street st 209') }
        .to raise_error ArgumentError
    end

    it 'getting access to instance attr by specified field (method)' do
      expect(person.name).to eq 'Jane Doe'
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

    it ':[]= Sets the value of the given struct member' do
      person[:name] = 'Katrine Show'
      expect(person[:name]).to eq 'Katrine Show'
    end

    it ':[]= Sets the value of the given index' do
      person[1] = 'New City'
      expect(person[:address]).to eq 'New City'
    end

    it ':to_a Returns the values for this struct as an Array.' do
      expect(person.to_a).to eq ["Jane Doe", "LA, Greenwood Sq 223"]
    end

    it ':to_a[index] Returns the attribute\'s value by specified index' do
      expect(person.to_a[0]).to eq 'Jane Doe'
    end

    it ':to_a[range] Returns the attribute\'s values by specified index range' do
      expect(person.to_a[0..1]).to eq ["Jane Doe", "LA, Greenwood Sq 223"]
    end

    it ':values Returns the values for this struct as an Array.' do
      expect(person.values).to eq ["Jane Doe", "LA, Greenwood Sq 223"]
    end

    it ':values[index] Returns the attribute\'s value by specified index' do
      expect(person.values[0]).to eq 'Jane Doe'
    end

    it ':values_at index Returns the attribute\'s value by specified index' do
      expect(person.values_at 0).to eq 'Jane Doe'
    end

    it ':values_at indexes Returns the attribute\'s values by specified indexes' do
      Person2 = described_class.new(:name, :address, :zip)
      prs2 = Person2.new("Bill", "City", 123)
      expect(prs2.values_at 0, 2).to eq ["Bill", 123]
    end

    it ':to_h Returns the hash of instance attributes' do
      inst_hash = { name: 'Jane Doe', address: 'LA, Greenwood Sq 223' }
      expect(person.to_h).to eq inst_hash
    end

    it ':to_h[:key] Returns the attribute\'s value by specified key' do
      expect(person.to_h[:name]).to eq 'Jane Doe'
    end

    it ':each Returns instance_vars values' do
      str = []
      person.each { |x| str << x }
      expect(str).to eq ['Jane Doe', 'LA, Greenwood Sq 223']
    end

    it ':each_pair Returns keys and values of instance_vars' do
      str = []
      person.each_pair { |k, v| str << [k, v] }
      expect(str).to eq [[:name, 'Jane Doe'],
                         [:address, 'LA, Greenwood Sq 223']]
    end

    it ':to_s and :inspect Return instance in string form' do
      expect(person.to_s).to eq "<factory Person name='Jane Doe' address='LA, Greenwood Sq 223'>"
      expect(person.inspect).to eq "<factory Person name='Jane Doe' address='LA, Greenwood Sq 223'>"
    end

    it ':members Returns array of instance_vars' do
      expect(person.members).to eq [:name, :address]
    end

    it ':size and :length Return count of instance_vars' do
      expect(person.size).to eq(2)
      expect(person.length).to eq(2)
    end

    it ':== Returns true if other has the same struct subclass and has equal member values ' do
      person_2 = Person.new('Jane Doe', 'LA, Greenwood Sq 223')
      expect(person == person_2).to eq true
    end

    it ':eql? Returns true if other has the same struct subclass and has equal member values ' do
      person_2 = Person.new('Jane Doe', 'LA, Greenwood Sq 223')
      expect(person.eql?(person_2)).to eq true
    end

    it ':hash Returns a hash value based on this struct\'s contents' do
      expect(person.hash.is_a?(Numeric)).to eq true
    end
  end
end
