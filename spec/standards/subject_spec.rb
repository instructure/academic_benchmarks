RSpec.describe Subject do
  include ObjectHelper

  let(:hash) do
    {
      "code" => "LANG"
    }
  end

  it "is instantiable with hash" do
    h = Subject.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
