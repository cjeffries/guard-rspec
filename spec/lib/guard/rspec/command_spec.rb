require "launchy"

require "guard/compat/test/helper"
require "guard/rspec/command"

RSpec.describe Guard::RSpec::Command do
  let(:options) { {} }
  let(:paths) { %w(path1 path2) }
  let(:command) { Guard::RSpec::Command.new(paths, options) }

  describe ".initialize" do

    it "sets paths at the end" do
      expect(command).to match /path1 path2$/
    end

    it "sets custom failure exit code" do
      expect(command).to match /--failure-exit-code 2/
    end

    it "sets formatter" do
      regexp = %r{-r .*/lib/guard/rspec_formatter.rb -f Guard::RSpecFormatter}
      expect(command).to match(regexp)
    end

    context "with custom cmd" do
      let(:options) { { cmd: "rspec -t ~slow" } }

      it "uses custom cmd" do
        expect(command).to match /^rspec -t ~slow/
      end
    end

    context "with RSpec defined formatter" do
      let(:formatters) { [%w(doc output)] }

      before do
        allow(RSpec::Core::ConfigurationOptions).to receive(:new) do
          double(options: { formatters: formatters })
        end
      end

      it "uses them" do
        expect(command).to match %r{-f doc -o output}
      end
    end

    context "with no RSpec defined formatter" do
      it "sets default progress formatter" do
        expect(command).to match %r{-f progress}
      end
    end

    context "with formatter in cmd" do
      let(:options) { { cmd: "rspec -f doc" } }

      it "sets no other formatters" do
        expect(command).to match %r{-f doc}
      end
    end

    context "with cmd_additional_args" do
      let(:options) { { cmd: "rspec", cmd_additional_args: "-f progress" } }

      it "uses them" do
        expect(command).to match %r{-f progress}
      end
    end

    context ":chdir option present" do
      let(:chdir) { "moduleA" }
      let(:paths) do
        %w[path1 path2].map { |p| "#{chdir}#{File::Separator}#{p}" }
      end

      let(:options) do
        {
          cmd: "cd #{chdir} && rspec",
          chdir: chdir
        }
      end

      it "removes chdir part from the path
        as it should be present in the cmd" do

        expect(command).to match %r{path1 path2}
      end
    end
  end

end
