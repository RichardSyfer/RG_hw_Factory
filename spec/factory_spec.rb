require './factory'

RSpec.describe 'Factory' do
  before(:all) do
    Person = Factory.new(:name, :address) do
      def to_s
        @name
      end
    end
  end

  describe 'create instance' do
    let(:person) { Person.new('Jane Doe', 'LA, Greenwood Sq 223') }
    it 'should create instance of Person cls' do
      expect(person).to be_instance_of Person
    end

    it 'should have all attribute accessors' do
      accessors = %i{name address}
      expect(Person.instance_methods).to include(*accessors)
    end

    it 'raise error when creating instance with wrong arguments number' do
      expect { Person.new('Jason', 'Timbuktu', 'KT, Street st 209') }
        .to raise_error RuntimeError, 'Error number of arguments'
    end
  end

end