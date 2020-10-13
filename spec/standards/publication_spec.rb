RSpec.describe Publication do
  include ObjectHelper

  let(:hash) do
    {
      "guid" => "964E0FEE-AD71-11DE-9BF2-C9169DFF4B22",
      "descr" => "Common Core State Standards",
      "authorities" => [{
        "acronym" => "CC",
        "descr" => "NGA Center/CCSSO",
        "guid" => "A83297F2-901A-11DF-A622-0C319DFF4B22"
      }]
    }
  end

  let(:p) { Publication.from_hash(hash) }

  it "is instantiable with hash" do
    compare_obj_to_hash(p, hash, ["authorities"])
    expect(p.authorities.first.is_a?(Authority)).to eq true
  end

  it "responds to description alias" do
    expect(p.description).to eq 'Common Core State Standards'
  end

  context ".rebranch_children" do
    it 'rebranches' do
      doc_hash = {
        'guid' => 'doc_guid',
        'descr' => 'doc_descr',
        'publication' => {
          'acronym' => 'pub',
          'descr' => 'my_pub',
          'guid' => p.guid,
          'authorities' => []
        }
      }
      sec_hash = {
        'descr' => 'my_sec',
        'guid' => 'sec_guid'
      }
      s1_hash = {
        'attributes' => {
          'guid' => 's1_guid',
          'document' => doc_hash,
          'section' => sec_hash
        }
      }
      s2_hash = {
        'attributes' => {
          'guid' => 's2_guid',
          'document' => doc_hash,
          'section' => sec_hash
        }
      }
      s1 = Standard.new(s1_hash)
      s2 = Standard.new(s2_hash)

      p.children << s1
      p.children << s2
      p.rebranch_children

      docs = p.children
      expect(docs.count).to eq 1
      expect(docs.first.class).to eq Document
      expect(docs.first.guid).to eq 'doc_guid'

      secs = docs.first.children
      expect(secs.count).to eq 1
      expect(secs.first.class).to eq Section
      expect(secs.first.guid).to eq 'sec_guid'

      stds = secs.first.children
      expect(stds.count).to eq 2
      expect(stds.first.class).to eq Standard
      expect(stds.map(&:guid).sort).to eq ['s1_guid', 's2_guid']
    end
  end
end
