RSpec.describe Statement do
  include ObjectHelper

  let(:hash) do
    {
      "descr" => "volume"
    }
  end

  let(:s) { Statement.from_hash(hash) }

  it "is instantiable with hash" do
    compare_obj_to_hash(s, hash)
  end

  it "responds to description alias" do
    expect(s.description).to eq 'volume'
  end
end