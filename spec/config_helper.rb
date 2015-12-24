module ConfigHelper
  def self.run_live?
    ENV["ACADEMIC_BENCHMARKS_RUN_LIVE"] == "1"
  end

  def self.partner_id_from_env
    ENV["ACADEMIC_BENCHMARKS_PARTNER_ID"]
  end

  def self.partner_key_from_env
    ENV["ACADEMIC_BENCHMARKS_PARTNER_KEY"]
  end
end
