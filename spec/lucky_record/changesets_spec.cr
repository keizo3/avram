require "../spec_helper"

class UserChangeset < User::BaseChangeset
  allow :name, :nickname

  def call
    add_name_error("is blank") if name.try &.blank?
  end
end

describe "LuckyRecord::Changeset" do
  describe "casting" do
    pending "it should cast integers, time objects, etc." do
    end
  end

  describe "getters" do
    it "creates a getter for all fields" do
      params = {"name" => "Paul", "nickname" => "Pablito"}

      changeset = UserChangeset.new_insert(params)

      changeset.name.should eq "Paul"
      changeset.nickname.should eq "Pablito"
      changeset.age.should eq nil
    end

    it "returns the value from params for updates" do
      user = UserBox.build
      params = {"name" => "New Name From Params"}

      changeset = UserChangeset.new_update(to: user, with: params)

      changeset.name.should eq params["name"]
      changeset.nickname.should eq user.nickname
      changeset.age.should eq user.age
    end
  end

  describe "params" do
    it "creates a param method for each of the allowed fields" do
      params = {"name" => "Paul", "nickname" => "Pablito"}

      changeset = UserChangeset.new_insert(params)

      changeset.name_param.should eq "Paul"
      changeset.nickname_param.should eq "Pablito"
    end
  end

  describe "errors" do
    it "creates an error method for each of the allowed fields" do
      params = {"name" => "Paul", "nickname" => "Pablito"}
      changeset = UserChangeset.new_insert(params)
      changeset.valid?.should be_true

      changeset.add_name_error "is not valid"

      changeset.valid?.should be_false
      changeset.name_errors.should eq ["is not valid"]
      changeset.nickname_errors.should eq [] of String
    end

    it "only returns unique errors" do
      params = {"name" => "Paul", "nickname" => "Pablito"}
      changeset = UserChangeset.new_insert(params)

      changeset.add_name_error "is not valid"
      changeset.add_name_error "is not valid"

      changeset.name_errors.should eq ["is not valid"]
    end
  end

  describe "fields" do
    pending "creates a field method for each of the allowed fields" do
    end
  end

  describe "#new_insert" do
    context "when valid with hash of params" do
      it "casts and inserts into the db, and return true" do
        params = {"name" => "Paul", "age" => "27", "joined_at" => Time.now.to_s}
        changeset = UserChangeset.new_insert(params)
        changeset.performed?.should be_false

        result = changeset.save

        result.should be_true
        changeset.performed?.should be_true
        UserRows.new.first.id.should be_truthy
      end
    end

    context "when valid with named tuple" do
      it "casts and inserts into the db, and return true" do
        changeset = UserChangeset.new_insert(name: "Paul", age: "27", joined_at: Time.now.to_s)
        changeset.performed?.should be_false

        result = changeset.save

        result.should be_true
        changeset.performed?.should be_true
        UserRows.new.first.id.should be_truthy
      end
    end

    context "invalid" do
      it "does not insert and returns false" do
        params = {"name" => "", "age" => "27", "joined_at" => Time.now.to_s}
        changeset = UserChangeset.new_insert(params)
        changeset.performed?.should be_false

        result = changeset.save

        result.should be_false
        changeset.performed?.should be_true
        UserRows.all.to_a.size.should eq 0
      end
    end
  end
end
