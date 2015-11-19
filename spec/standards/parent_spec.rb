RSpec.describe Parent do
  include ObjectHelper

  let(:hash) do
    {
       "guid" => "CEC34096-67AD-11DF-AB5F-995D9DFF4B22"
    }
  end

  it "is instantiable with hash" do
    h = Parent.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
