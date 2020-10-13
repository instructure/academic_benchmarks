RSpec.describe Number do
  include ObjectHelper

  let(:hash) do
    {
      "enhanced" => "2.a.i",
      "raw" => "i."
    }
  end

  it "is instantiable with hash" do
    h = Number.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
