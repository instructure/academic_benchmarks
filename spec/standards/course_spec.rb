RSpec.describe Course do
  include ObjectHelper

  let(:hash) do
    {
      "descr" => "College- and Career-Readiness Anchor Standards",
      "guid" => "CF69C79A-67AD-11DF-AB5F-995D9DFF4B22"
    }
  end

  it "is instantiable with hash" do
    h = Course.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
