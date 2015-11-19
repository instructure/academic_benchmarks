module ObjectHelper
  def compare_obj_to_hash(obj, hash, ignore_keys = [])
    hash.each do |key, val|
      unless ignore_keys.include?(key)
        expect(obj).to respond_to(key)
        expect(obj.public_send(key)).to eq(val)
      end
    end
  end
end
