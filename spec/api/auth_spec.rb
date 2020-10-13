RSpec.describe Auth do
  SIGNATURE_WITH_UID = {
    '1446901332' => "JNjoil2nHbanfhGuptsI8St8HMNTky5hb+hZ7SPeYRY=",
    '1446908332' => "HCBvgawA/conTB9GIKyo41nXflxAnVEvgrMND9qBny0=",
    '1446909332' => "OAH8T6IVVDc50HubV0boIJl2rGn9slNOWH+sATK7pNk="
  }

  SIGNATURE_WITHOUT_UID = {
    '1446901332' => "+cDJSAQBejS2RTUrRRLUn05Q28b+lMZMLRKxAyaFY28=",
    '1446908332' => "+Lpds+Kkz6+OQ3TJrM0fpk9ojaRLGnZiL9T8FUdQ0C0=",
    '1446909332' => "Rj7mycWLuemFbLVb2mB9i2uqXVKAL+Cs/rDmqycBd/U="
  }

  def message(expires:, user_id: '')
    if user_id.empty?
      "#{expires}"
    else
      "#{expires}\n#{user_id}"
    end
  end

  context "smoke test" do
    context "signature" do
      it "returns a signature with no user ID" do
        expect(Auth.signature_for(
          partner_key: ApiHelper::Fixtures::PARTNER_KEY,
          message: message(expires: Time.now.to_i)
        )).not_to be_empty
      end

      it "returns a signature with user ID" do
        expect(Auth.signature_for(
          partner_key: ApiHelper::Fixtures::PARTNER_KEY,
          message: message(
            expires: Time.now.to_i,
            user_id: ApiHelper::Fixtures::USER_ID
          )
        )).not_to be_empty
      end
    end

    it "returns some auth_query_params" do
      expect(Auth.auth_query_params(
        partner_id: ApiHelper::Fixtures::PARTNER_ID,
        partner_key: ApiHelper::Fixtures::PARTNER_KEY,
        expires: Time.now.to_i,
        user_id: ApiHelper::Fixtures::USER_ID
      )).not_to be_empty
    end

    it "excludes user_id if empty" do
      expect(Auth.auth_query_params(
        partner_id: ApiHelper::Fixtures::PARTNER_ID,
        partner_key: ApiHelper::Fixtures::PARTNER_KEY,
        expires: Time.now.to_i,
        user_id: ""
      )).not_to have_key(:user_id)
    end
  end

  context "correct signature" do
    it "returns the correct signature with user id" do
      SIGNATURE_WITH_UID.each do |expires, expected|
        expect(Auth.signature_for(
          partner_key: ApiHelper::Fixtures::PARTNER_KEY,
          message: message(expires: expires, user_id: ApiHelper::Fixtures::USER_ID)
        )).to eq(expected)
      end
    end

    it "returns the correct signature without user id" do
      SIGNATURE_WITHOUT_UID.each do |expires, expected|
        expect(Auth.signature_for(
          partner_key: ApiHelper::Fixtures::PARTNER_KEY,
          message: message(expires: expires, user_id: '')
        )).to eq(expected)
      end
    end
  end

  context "auth query params" do
    it "generates the correct auth_query_params with user id" do
      SIGNATURE_WITH_UID.each do |expires, signature|
        expect(Auth.auth_query_params(
          partner_id: ApiHelper::Fixtures::PARTNER_ID,
          partner_key: ApiHelper::Fixtures::PARTNER_KEY,
          expires: expires,
          user_id: ApiHelper::Fixtures::USER_ID
        )).to eq({
          "partner.id" => ApiHelper::Fixtures::PARTNER_ID,
          "auth.signature" => signature,
          "auth.expires" => expires,
          "user.id" => ApiHelper::Fixtures::USER_ID
        })
      end
    end

    it "generates the correct auth_query_params without user id" do
      SIGNATURE_WITHOUT_UID.each do |expires, signature|
        expect(Auth.auth_query_params(
          partner_id: ApiHelper::Fixtures::PARTNER_ID,
          partner_key: ApiHelper::Fixtures::PARTNER_KEY,
          expires: expires
        )).to eq({
          "partner.id" => ApiHelper::Fixtures::PARTNER_ID,
          "auth.signature" => signature,
          "auth.expires" => expires
        })
      end
    end
  end

  context "expire time" do
    DRIFT_TOLERANCE = 1 # second

    def compare_tolerance(actual, expected)
      actual >= expected - DRIFT_TOLERANCE &&
      actual <= expected + DRIFT_TOLERANCE
    end

    it "10 seconds from now" do
      expect(compare_tolerance(
        Auth.expire_time_in_10_seconds,
        Time.now.to_i + 10
      )).to be_truthy
    end

    it "2 hours from now" do
      expect(compare_tolerance(
        Auth.expire_time_in_2_hours,
        Time.now.to_i + 7200
      )).to be_truthy
    end

    it "expires arbitrary times in the future" do
      CASES = {
        30.minutes => Time.now.to_i + 1800,
        17.minutes => Time.now.to_i + 1020,
        3.hours    => Time.now.to_i + 10800,
        3.days     => Time.now.to_i + 259200
      }

      CASES.each do |input, expected|
        actual = Auth.expire_time_in(input)
        expect(compare_tolerance(actual, expected)).to be_truthy
      end
    end
  end
end
