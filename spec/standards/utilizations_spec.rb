RSpec.describe Utilizations do
  include ObjectHelper

  let(:hash) do
    {
      "type" => "alignable"
    }
  end

  it "is instantiable with hash" do
    h = Utilizations.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end