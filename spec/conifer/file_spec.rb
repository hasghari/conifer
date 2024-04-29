# frozen_string_literal: true

require 'climate_control'
require 'conifer/file'

RSpec.describe Conifer::File do
  subject(:file) do
    described_class.new(name, dir:, format:, prefix:, permitted_classes:)
  end

  let(:name) { :foo }
  let(:dir) { File.expand_path(__dir__) }
  let(:format) { :yml }
  let(:prefix) { nil }
  let(:permitted_classes) { [] }

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
        expect(file.exists?).to be true
      end
    end

    context 'when file does not exist' do
      let(:name) { :missing }

      it 'returns false' do
        expect(file.exists?).to be false
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

    context 'with json format' do
      let(:format) { :json }

      it 'returns parsed content of file' do
        ClimateControl.modify AWS_SECRET_KEY: 'secret' do
          expect(file.parsed).to eq('foo' => 'bar',
                                    'development' => { 'aws' => { 'secret_key' => 'secret' }, 'log_level' => 'debug' },
                                    'test' => { 'log_level' => 'fatal' })
        end
      end
    end

    context 'with unsupported format' do
      let(:format) { :ruby }

      it 'raises error' do
        expect { file.parsed }.to raise_error Conifer::File::UnsupportedFormatError
      end
    end

    context 'with non-primitive values' do
      let(:name) { :dates }

      context 'when type is not whitelisted' do
        it 'raises error' do
          expect { file.parsed }.to raise_error Psych::DisallowedClass
        end
      end

      context 'when type is whitelisted' do
        let(:permitted_classes) { [Date] }

        it 'does not raise error' do
          expect { file.parsed }.not_to raise_error
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
