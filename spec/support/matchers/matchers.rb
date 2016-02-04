RSpec::Matchers.define :be_indexable do

  match do |klass|
    klass < AgnosticBackend::Indexable
  end

end


RSpec::Matchers.define :define_index_field do |name, for_index: nil, type: nil, **expected_custom_attributes|

  match do |klass|
    for_index = klass.index_name if for_index.nil?
    manager = klass.index_content_manager(for_index)
    manager.nil? and next false
    field = manager.contents[name.to_s]
    field.nil? and next false
    type_matches?(field, type) &&
      custom_attributes_match?(field, expected_custom_attributes) rescue false
  end

  def type_matches?(field, expected_type)
    return true if expected_type.nil?
    field.type.matches?(expected_type)
  end

  def custom_attributes_match?(field, expected_attributes)
    return true if expected_attributes.empty?
    field.type.options == expected_attributes
  end

end
