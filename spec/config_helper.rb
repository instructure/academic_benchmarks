module ConfigHelper
  def self.run_live?
    ENV["ACADEMIC_BENCHMARKS_RUN_LIVE"] == "1"
  end
end
