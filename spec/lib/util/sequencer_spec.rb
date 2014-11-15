require 'spec_helper'

describe Util::Sequencer do
  describe '.next_id' do
    context 'when called many times' do
      context 'with same keys' do
        it 'increases sequence' do
          foo_1 = Util::Sequencer.next_id(:foo)
          foo_2 = Util::Sequencer.next_id(:foo)

          expect(Util::Sequencer.next_id(:foo)).to eq(foo_1 + 2)
        end

        context 'and same versions' do
          it 'increases sequence' do
            foo_1 = Util::Sequencer.next_id(:foo, version: 1)
            foo_2 = Util::Sequencer.next_id(:foo, version: 1)

            expect(Util::Sequencer.next_id(:foo, version: 1)).to eq(foo_1 + 2)
          end
        end

        context 'and different versions' do
          it "doesn't increase sequence" do
            foo_1 = Util::Sequencer.next_id(:foo, version: 1)
            foo_2 = Util::Sequencer.next_id(:foo, version: 2)

            expect(Util::Sequencer.next_id(:foo, version: 1)).to eq(foo_1 + 1)
            expect(Util::Sequencer.next_id(:foo, version: 2)).to eq(foo_2 + 1)
          end
        end
      end

      context 'with different keys' do
        it "doesn't increase sequence" do
          foo = Util::Sequencer.next_id(:foo)
          bar = Util::Sequencer.next_id(:bar)

          expect(Util::Sequencer.next_id(:foo)).to eq(foo + 1)
          expect(Util::Sequencer.next_id(:bar)).to eq(bar + 1)
        end

        context 'and same versions' do
          it "doesn't increase sequence" do
            foo = Util::Sequencer.next_id(:foo, version: 1)
            bar = Util::Sequencer.next_id(:bar, version: 1)

            expect(Util::Sequencer.next_id(:foo, version: 1)).to eq(foo + 1)
            expect(Util::Sequencer.next_id(:bar, version: 1)).to eq(bar + 1)
          end
        end

        context 'and different versions' do
          it "doesn't increase sequence" do
            foo = Util::Sequencer.next_id(:foo, version: 1)
            bar = Util::Sequencer.next_id(:bar, version: 2)

            expect(Util::Sequencer.next_id(:foo, version: 1)).to eq(foo + 1)
            expect(Util::Sequencer.next_id(:bar, version: 2)).to eq(bar + 1)
          end
        end
      end
    end

    context 'with md5 option' do
      it 'returns digest of next value' do
        foo_1 = Util::Sequencer.next_id(:foo)
        foo_2 = Util::Sequencer.next_id(:foo, md5: true)

        expect(foo_2).to be_kind_of(Digest::MD5)
        expect(foo_2).to eq(Digest::MD5.new.update((foo_1 + 1).to_s))
      end
    end
  end
end
