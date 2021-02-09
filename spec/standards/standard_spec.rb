require 'hash_dig_and_collect'

RSpec.describe Standard do
  include ObjectHelper

  let(:api_response) do
    JSON.parse(ApiHelper::Fixtures.all_standards_response)
  end

  let(:standard) { Standard.new(api_response["data"].first) }

  def send_chain(obj, arr)
    arr.inject(obj) do |o, a|
      o.is_a?(Array) ? o.map {|i| i.send(a) } : o.send(a)
    end
  end

  def compare_obj_to_hash_path(obj, hash, path)
    # dig_and_collect will return values in array,
    # even if an intermediate hash value wasn't array,
    # so coerce the left hand side into an array.
    expect(Array(send_chain(obj, path)).compact).to eq(hash.dig_and_collect(*path).compact), "failed to match on #{path.join(',')}"
  end

  it "is instantiable from hash" do
    api_response["data"].each do |resource|
      attrs = resource['attributes']
      s = Standard.new(resource)
      expect(s).not_to be_nil
      compare_obj_to_hash_path(s, attrs, ['guid'])
      compare_obj_to_hash_path(s, attrs, ['label'])
      compare_obj_to_hash_path(s, attrs, ['status'])
      compare_obj_to_hash_path(s, attrs, ['number', 'prefix_enhanced'])
      compare_obj_to_hash_path(s, attrs, ['disciplines', 'subjects', 'code'])
      compare_obj_to_hash_path(s, attrs, ['statement', 'descr'])
      compare_obj_to_hash_path(s, attrs, ['section', 'guid'])
      compare_obj_to_hash_path(s, attrs, ['section', 'descr'])
      compare_obj_to_hash_path(s, attrs, ['education_levels', 'grades', 'code'])
      compare_obj_to_hash_path(s, attrs, ['document', 'descr'])
      compare_obj_to_hash_path(s, attrs, ['document', 'adopt_year'])
      compare_obj_to_hash_path(s, attrs, ['document', 'guid'])
      compare_obj_to_hash_path(s, attrs, ['document', 'publication', 'descr'])
      compare_obj_to_hash_path(s, attrs, ['document', 'publication', 'guid'])
      compare_obj_to_hash_path(s, attrs, ['document', 'publication', 'authorities', 'descr'])
      compare_obj_to_hash_path(s, attrs, ['document', 'publication', 'authorities', 'acronym'])
      compare_obj_to_hash_path(s, attrs, ['document', 'publication', 'authorities', 'guid'])
      compare_obj_to_hash_path(s, attrs, ['utilizations', 'type'])
      expect(s.parent_guid).to eq resource.dig('relationships', 'parent', 'data', 'id')
    end
  end

  it "sets parent_guid to nil when there is no parent in the hash" do
    hash = api_response["data"].first
    expect(hash["relationships"].delete("parent")).not_to be_nil
    expect(Standard.new(hash).parent_guid).to be_nil
  end

  it "properly sets the parent_guid" do
    parent_guid = SecureRandom.uuid
    hash = api_response["data"].first
    expect(Standard.new(hash).parent_guid).not_to be_nil
    hash["relationships"]["parent"]["data"]["id"] = parent_guid
    expect(Standard.new(hash).parent_guid).to eq(parent_guid)
  end

  context "children" do
    let(:parent) { Standard.new(api_response["data"][0]) }
    let(:child1) { Standard.new(api_response["data"][1]) }
    let(:child2) { Standard.new(api_response["data"][2]) }

    it "can be added to the standard" do
      expect{
        parent.add_child(child1)
      }.to change{parent.children}.from([]).to([child1])
      expect{
        child1.add_child(child2)
      }.not_to change{parent.children.count}
      expect{
        parent.add_child(child2)
      }.to change{parent.children.count}.from(1).to(2)
      expect(parent.children).to match_array([child1, child2])
    end

    it "can be removed from the standard" do
      [child1, child2].each { |c| parent.add_child(c) }
      expect{
        parent.remove_child(child1)
      }.to change{parent.children}.from([child1, child2]).to([child2])
      expect{
        parent.remove_child(child1)
      }.not_to change{parent.children}
      expect{
        parent.remove_child(child2)
      }.to change{parent.children}.from([child2]).to([])
    end

    it "sets the parent of its child to itself" do
      expect{
        parent.add_child(child1)
      }.to change{child1.parent}.from(nil).to(parent)
    end
  end

  context "grades" do
    let(:ed_levels) do
      EducationLevels.new(grades: [
        {
          code: "low man"
        },
        {
          code: "So high"
        }
      ])
    end

    it "cascades grades properly" do
      s1 = StandardsHelper.standard
      s1.education_levels = ed_levels
      last_standard = s1
      10.times do |i|
        last_standard.add_child(StandardsHelper.standard)
        last_standard = last_standard.children.first
        last_standard.number = i
        last_standard.education_levels = nil
      end
      expect(s1).to have_children
      expect(s1.education_levels.grades.first).to eq(ed_levels.grades.first)
      expect(s1.education_levels.grades.last).to eq(ed_levels.grades.last)
      expect(last_standard).not_to have_children
      expect(last_standard.instance_variable_get("@education_levels")).to be_nil
      expect(last_standard.education_levels).not_to be_nil
      expect(last_standard.education_levels.grades.first).to eq(ed_levels.grades.first)
      expect(last_standard.education_levels.grades.last).to eq(ed_levels.grades.last)
    end
  end
end
