# frozen_string_literal: true

RSpec.describe Conifer do
  it 'has a version number' do
    expect(Conifer::VERSION).not_to be_nil
  end

  describe '::conifer' do
    context 'with default parameters' do
      let(:model) do
        Class.new do
          include Conifer

          conifer :bar
        end
      end

      it 'creates a method with the same name' do
        expect(model.new.bar).to be_a Conifer::File
      end
    end

    context 'with overridden directory' do
      let(:model) do
        Class.new do
          include Conifer

          conifer :foo, dir: File.expand_path('./config', __dir__)
        end
      end

      it 'finds correct file' do
        expect(model.new.foo.path).to match 'spec/config/foo.yml'
      end
    end

    context 'with overridden method name' do
      let(:model) do
        Class.new do
          include Conifer

          conifer :bar, method: :foo
        end
      end

      it 'creates method with overridden name' do
        expect(model.new.foo).to be_a Conifer::File
      end

      it 'raises error for default method name' do
        expect { model.new.bar }.to raise_error NoMethodError
      end
    end

    context 'with overridden format' do
      let(:model) do
        Class.new do
          include Conifer

          conifer :bar, format: :json
        end
      end

      it 'finds correct file' do
        expect(model.new.bar.path).to match 'spec/bar.json'
      end
    end

    context 'when singleton is true' do
      let(:model) do
        Module.new do
          include Conifer

          conifer :bar, singleton: true
        end
      end

      it 'defines method at class level' do
        expect(model.bar).to be_a Conifer::File
      end
    end
  end
end
