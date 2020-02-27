# frozen_string_literal: true

require 'climate_control'
require 'conifer/file'

RSpec.describe Conifer::File do
  subject(:file) { described_class.new(name, dir: dir, prefix: prefix) }

  let(:name) { :foo }
  let(:dir) { File.expand_path(__dir__) }
  let(:prefix) { nil }

  describe '#path' do
    context 'when file is in current directory' do
      it 'returns path to file' do
        expect(file.path).to match 'spec/conifer/foo.yml'
      end
    end

    context 'when file is in other directory' do
      let(:dir) { File.expand_path('../config', __dir__) }

      it 'returns path to file' do
        expect(file.path).to match 'spec/config/foo.yml'
      end
    end

    context 'when file is in parent directory' do
      let(:name) { :bar }
      let(:dir) { File.expand_path('..', __dir__) }

      it 'returns path to file' do
        expect(file.path).to match 'spec/bar.yml'
      end
    end
  end

  describe '#exists?' do
    context 'when file exists' do
      it 'returns true' do
        expect(file.exists?).to eq true
      end
    end

    context 'when file does not exist' do
      let(:name) { :missing }

      it 'returns false' do
        expect(file.exists?).to eq false
      end
    end
  end

  describe '#validate!' do
    context 'when file exists' do
      it 'does not raise error' do
        expect { file.validate! }.not_to raise_error
      end
    end

    context 'when file does not exist' do
      let(:name) { :missing }

      it 'raises error' do
        expect { file.validate! }.to raise_error Conifer::File::NotFoundError
      end
    end
  end

  describe '#parsed' do
    context 'when env variable is missing' do
      it 'returns parsed content of file' do
        expect(file.parsed).to eq('foo' => 'bar',
                                  'development' => { 'aws' => { 'secret_key' => 12345 }, 'log_level' => 'debug' },
                                  'test' => { 'log_level' => 'fatal' })
      end
    end

    context 'when env variable is set' do
      it 'returns value from environment variable' do
        ClimateControl.modify AWS_SECRET_KEY: 'secret' do
          expect(file.parsed).to eq('foo' => 'bar',
                                    'development' => { 'aws' => { 'secret_key' => 'secret' }, 'log_level' => 'debug' },
                                    'test' => { 'log_level' => 'fatal' })
        end
      end
    end
  end

  describe '#[]' do
    context 'with no prefix' do
      it 'returns value for key' do
        expect(file['foo']).to eq 'bar'
      end
    end

    context 'with prefix' do
      let(:prefix) { 'development' }

      it 'returns value for key' do
        expect(file['log_level']).to eq 'debug'
      end
    end

    context 'with nested key' do
      let(:prefix) { 'development' }

      it 'returns value for key' do
        expect(file['aws.secret_key']).to eq 12345
      end
    end
  end
end
