# frozen_string_literal: true

RSpec.describe Conifer do
  it 'has a version number' do
    expect(Conifer::VERSION).not_to be nil
  end

  describe '::conifer' do
    after do
      Object.send :remove_const, :Model
    end

    context 'with default parameters' do
      before do
        Model = Class.new do
          include Conifer

          conifer :bar
        end
      end

      it 'creates a method with the same name' do
        expect(Model.new.bar).to be_a Conifer::File
      end
    end

    context 'with overridden directory' do
      before do
        Model = Class.new do
          include Conifer

          conifer :foo, dir: File.expand_path('./config', __dir__)
        end
      end

      it 'finds correct file' do
        expect(Model.new.foo.path).to match 'spec/config/foo.yml'
      end
    end

    context 'with overridden method name' do
      before do
        Model = Class.new do
          include Conifer

          conifer :bar, method: :foo
        end
      end

      it 'creates method with overridden name' do
        expect(Model.new.foo).to be_a Conifer::File
      end

      it 'raises error for default method name' do
        expect { Model.new.bar }.to raise_error NoMethodError
      end
    end

    context 'when singleton is true' do
      before do
        Model = Module.new do
          include Conifer

          conifer :bar, singleton: true
        end
      end

      it 'defines method at class level' do
        expect(Model.bar).to be_a Conifer::File
      end
    end
  end
end
