require 'agnostic_backend/version'
require 'active_record'
require 'active_support/core_ext'

require 'agnostic_backend/utilities'
require 'agnostic_backend/indexable'
require 'agnostic_backend/index'
require 'agnostic_backend/indexer'

require 'agnostic_backend/queryable/tree_node'
require 'agnostic_backend/queryable/attribute'
require 'agnostic_backend/queryable/value'
require 'agnostic_backend/queryable/criteria_builder'
require 'agnostic_backend/queryable/query_builder'
require 'agnostic_backend/queryable/executor'
require 'agnostic_backend/queryable/query'
require 'agnostic_backend/queryable/result_set'
require 'agnostic_backend/queryable/visitor'
require 'agnostic_backend/queryable/validator'

require 'agnostic_backend/queryable/criteria/criterion'
require 'agnostic_backend/queryable/criteria/binary'
require 'agnostic_backend/queryable/criteria/ternary'

require 'agnostic_backend/queryable/operations/operation'
require 'agnostic_backend/queryable/operations/unary'
require 'agnostic_backend/queryable/operations/n_ary'

require 'agnostic_backend/queryable/expressions/expression'

module AgnosticBackend

end
