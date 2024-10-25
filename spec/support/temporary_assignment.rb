# frozen_string_literal: true

module TemporaryAssignment
  def with_temporary_assignment(assignee, attribute, temporary_value)
    predicate = "#{attribute}?"
    attribute_reader = assignee.respond_to?(predicate) ? predicate : attribute
    attribute_writer = "#{attribute}="

    original_value = assignee.public_send(attribute_reader)
    assignee.public_send(attribute_writer, temporary_value)
    yield
  ensure
    assignee.public_send(attribute_writer, original_value)
  end
end
