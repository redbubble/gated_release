require "spec_helper"
require "gated_release"

describe GatedRelease do
  it "has a version number" do
    expect(GatedRelease::VERSION).not_to be nil
  end
end
