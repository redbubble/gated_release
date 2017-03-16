require "generator_spec"

module GatedRelease
  module Generators
    describe InstallGenerator, :type => :generator do

      root_dir = File.expand_path("../../../../tmp", __FILE__)
      puts root_dir
      destination root_dir

      before :all do
        prepare_destination
        run_generator
      end

      it "creates the installation db migration" do
        migration_file =
          Dir.glob("#{root_dir}/db/migrate/*create_gated_release_gates.rb")

        assert_file migration_file[0],
          /class CreateGatedReleaseGates < ActiveRecord::Migration/
      end
    end
  end
end
