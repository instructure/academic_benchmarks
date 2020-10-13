RSpec.describe Grade do
  include ObjectHelper

  let(:hash) do
    {
      "code" => "K"
    }
  end

  it "is instantiable with hash" do
    h = Grade.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
