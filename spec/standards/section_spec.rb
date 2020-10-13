RSpec.describe Section do
  include ObjectHelper

  let(:hash) do
    {
      "descr" => "College- and Career-Readiness Anchor Standards",
      "guid" => "CF69C79A-67AD-11DF-AB5F-995D9DFF4B22"
    }
  end

  let(:s) { Section.from_hash(hash) }

  it "is instantiable with hash" do
    compare_obj_to_hash(s, hash)
  end

  it "responds to description alias" do
    expect(s.description).to eq 'College- and Career-Readiness Anchor Standards'
  end
end
