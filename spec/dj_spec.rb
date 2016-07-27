require 'spec_helper'

describe Dj, type: :model do
    it { should have_and_belong_to_many(:songs) }
  describe '#request' do
    it "subtracts requests by 1" do
      test_dj = Dj.create({name: 'tst', requests: 4})
      test_dj.request
      expect(test_dj.requests).to eq 3
    end
  end
end
