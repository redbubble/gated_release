require "spec_helper"

describe GatedRelease::Gate do
  describe "#get" do
    it "creates a gate if one not found" do
      expect(described_class.get("my_gate").name).to eq("my_gate")
      expect(described_class.find_by_name("my_gate")).not_to be_nil
    end
  end

  describe "open!" do
    let(:gate) { described_class.get("my_gate") }

    it "opens the gate" do
      expect(gate.state).to eq("limited")
      gate.open!
      expect(gate.state).to eq("open")
    end
  end

  let(:name) { 'my_release'}

  let(:open_stub) { double }
  let(:closed_stub) { double }

  let(:open_block) { -> { open_stub.a_method } }
  let(:closed_block) { -> { closed_stub.a_method } }

  let(:run_args) { {open: open_block, closed: closed_block} }

  subject { described_class.get(name) }

  describe '#run' do

    context 'when gate does not exists' do

      it 'creates a gate that runs old code' do
        expect(closed_stub).to receive(:a_method)
        subject.run(run_args)
      end
    end

    context 'when gate is open' do

      before do
        subject.open!
      end

      let(:run_args) { {open: open_block, closed: closed_block} }

      it 'runs new code' do
        expect(open_stub).to receive(:a_method)
        subject.run(run_args)
      end

      context "when close_on_error" do
        let(:open_block) { -> { raise NotImplementedError } }

        it 'closes the gate' do
          expect(subject.state).to eq(described_class::OPEN)
          expect {
            subject.run(run_args.merge(close_on_error: true))
          }.to raise_error(NotImplementedError)
          expect(subject.state).to eq(described_class::CLOSED)
        end
      end

      describe 'error handling' do

        context 'when the argument is missing the :open_block or :open key' do

          it 'displays a useful error message' do
            run_args.delete(:open)
            expect{ subject.run(run_args) }.to raise_error(KeyError, 'key not found: :open for gated release: my_release')
          end
        end
      end
    end

    context 'when the gate is closed' do

      before do
        subject.state = described_class::CLOSED
        subject.attempts = 0
        allow(closed_stub).to receive(:a_method)
      end

      it 'does not increment the counter' do
        subject.run(run_args)
        expect(subject.attempts).to eq 0
      end

      it 'runs new code' do
        expect(closed_stub).to receive(:a_method)
        subject.run(run_args)
      end

      context 'and the max_attempts has not been reached' do
        it 'runs the old code' do
          expect(closed_stub).to receive(:a_method)
          subject.run(run_args)
        end
      end
    end

    context "when the gate is percentage" do
      before do
        subject.state = described_class::PERCENTAGE
        subject.percent_open = 50
      end

      context "and luck is in your favour" do
        before do
          expect(Kernel).to receive(:rand).with(100).and_return(49)
        end
        it 'runs new code' do
          expect(open_stub).to receive(:a_method)
          subject.run(run_args)
        end
      end

      context "and luck is NOT in your favour" do
        before do
          expect(Kernel).to receive(:rand).with(100).and_return(51)
        end
        it 'runs new code' do
          expect(closed_stub).to receive(:a_method)
          subject.run(run_args)
        end
      end
    end

    context 'when gate is limited' do

      it 'creates a gate that runs old code' do
        expect(closed_stub).to receive(:a_method)
        subject.run(run_args)
      end

      context 'and the max_attempts is not reached' do

        before do
          subject.allow_more!(1)
        end

        it 'runs the new code' do
          expect(open_stub).to receive(:a_method)
          subject.run(run_args)
        end
      end
    end

    describe 'error handling' do

      context 'when the argument is missing the :closed_block or :closed key' do

        it 'displays a useful error message' do
          run_args.delete(:closed)
          expect{ subject.run(run_args) }.to raise_error(KeyError, 'key not found: :closed for gated release: my_release')
        end
      end

    end
  end

  describe '#max_attempts' do

    context 'when gate does not exists' do

      it 'is zero' do
        expect(subject.max_attempts).to eq 0
      end
    end

    context 'when allowing more' do

      before do
        subject.allow_more!(100)
      end

      it 'is increased' do
        expect(subject.max_attempts).to eq 100
      end

      context 'when allowing more on existing gate' do

        before do
          subject.allow_more!(7)
        end

        it 'increments by specified count' do
          expect(subject.max_attempts).to eq 107
        end
      end
    end
  end

  describe '#allow_more!' do

    context 'when gate does not exists' do

      let(:count) { 7 }

      it 'increments the max_attempts by specified count' do
        subject.allow_more!(7)
        expect(subject.max_attempts).to eq 7
      end
    end
  end

  describe "#open!" do
    it "saves it in state open" do
      subject.state = 'closed'
      subject.save!

      subject.open!
      subject.reload
      expect(subject.state).to eq 'open'
    end
  end

  describe "#close!" do
    it "saves it in state closed" do
      subject.state = 'open'
      subject.save!

      subject.close!
      subject.reload
      expect(subject.state).to eq 'closed'
    end
  end

  describe "#limit!" do
    it "saves it in state limited" do
      subject.state = 'open'
      subject.save!

      subject.limit!
      subject.reload
      expect(subject.state).to eq 'limited'
    end
  end

  describe "#percentage!" do
    it "saves it in state percentage" do
      subject.state = 'open'
      subject.save!

      subject.percentage!(60)
      subject.reload
      expect(subject.state).to eq 'percentage'
      expect(subject.percent_open).to eq 60
    end
  end

  describe '#attempts' do

    context 'when gate does not exists' do

      it 'is zero' do
        expect(subject.attempts).to eq 0
      end
    end

    context 'after 1 attempt' do

      before do
        subject.allow_more!(1)
        expect(open_stub).to receive(:a_method)
        subject.run(run_args)
      end

      it 'increments the attempt counter' do
        expect(subject.attempts).to eq 1
      end
    end

  end
end
