require 'spec_helper.rb'

describe Song, type: :model do
  it { should have_and_belong_to_many(:users) }
  describe '#vote' do
    it "change spin_score" do
      test_song = Song.create({spin_score: 0})
      test_song.vote(-1)
      expect(test_song.spin_score).to eq -1
    end
  end
end
