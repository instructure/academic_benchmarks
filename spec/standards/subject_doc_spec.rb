RSpec.describe SubjectDoc do
  include ObjectHelper

  let(:hash) do
    {
      "descr" => "English Language Arts/Literacy (2010)",
      "guid" => "CF6A375C-67AD-11DF-AB5F-995D9DFF4B22"
    }
  end

  it "is instantiable with hash" do
    h = SubjectDoc.from_hash(hash)
    compare_obj_to_hash(h, hash)
  end
end
