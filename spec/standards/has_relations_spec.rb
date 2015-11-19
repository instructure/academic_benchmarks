RSpec.describe HasRelations do
  include ObjectHelper

  let(:hash) do
    {
      "derivative" => 1
    }
  end

  it "is instantiable with hash" do
    h = HasRelations.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
