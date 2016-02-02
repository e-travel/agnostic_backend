require 'spec_helper'

describe AgnosticStore do
  it 'has a version number' do
    expect(AgnosticStore::VERSION).not_to be nil
  end
end
