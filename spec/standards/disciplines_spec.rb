RSpec.describe Disciplines do
  let(:hash) do
    {
      "subjects" => [{
        "code" => "LANG"
      }]
    }
  end

  it "is instantiable with hash" do
    h = Disciplines.from_hash(hash)
    expect(h.subjects.first.is_a?(Subject)).to eq true
  end
end
