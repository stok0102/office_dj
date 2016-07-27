require 'spec_helper.rb'

describe User, type: :model do
  describe "#username" do
    it "will return the username for a user" do
      test_user = User.new(:username => "djrock", :password => "12345")
      test_user.save
      expect(test_user.username).to eq("djrock")
    end
  end

  describe '#authenticate' do
    it 'will return true for an authenticated user' do
      test_user = User.new(:username => "djrock", :password => "12345")
      test_user.save
      expect(test_user.authenticate(12345)).to eq(true)
    end
  end

  describe '.create' do
    it 'will create a new user and save to database' do
      test_user = User.create(:username => "djrock", :password => "12345")
      expect(test_user.id).to(be_an_instance_of(Fixnum))
    end
  end

  it { should have_and_belong_to_many(:songs) }
end
