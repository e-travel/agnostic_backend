require 'spec_helper'

describe AgnosticBackend::Indexable::ObjectObserver do

  class Child < Struct.new(:parent)
    include AgnosticBackend::Indexable
  end

  class Parent < Struct.new(:child)
    include AgnosticBackend::Indexable
  end

  let(:parent) { Parent.new }
  let(:child) { Child.new(parent) }

  before do
    parent.child = child
    Parent.send(:define_index_fields, owner: Child) { struct :child, from: Child }
    Child.send(:define_index_fields) { struct :parent, from: Parent }
  end

  it 'should catch the circular reference' do
    expect{child.generate_document}.to raise_error(AgnosticBackend::Indexable::CircularReferenceError)
  end

end
