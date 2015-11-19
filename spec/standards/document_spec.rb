RSpec.describe Document do
  include ObjectHelper

  let(:hash) do
    {
      "guid" => "964E0FEE-AD71-11DE-9BF2-C9169DFF4B22",
      "title" => "Common Core State Standards"
    }
  end

  it "is instantiable with hash" do
    h = Document.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
