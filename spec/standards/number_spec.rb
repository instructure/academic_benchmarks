RSpec.describe Number do
  include ObjectHelper

  let(:hash) do
    {
      "prefix_enhanced" => "LA.9-12.3.0"
    }
  end

  it "is instantiable with hash" do
    h = Number.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
