RSpec.describe EducationLevels do
  include ObjectHelper

  let(:hash) do
    {
      "grades" => [{
        "code" => "K"
      }]
    }
  end

  it "is instantiable with hash" do
    h = EducationLevels.from_hash(hash)
    expect(h.grades.first.is_a?(Grade)).to eq true
  end
end
