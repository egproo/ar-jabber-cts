# This is a fix for SystemStackError:
#   https://github.com/mtaylor/Rails-Inverse-Nested-Attr-Bug
# Rails bug:
#   https://github.com/rails/rails/issues/7809

module ActiveRecord
  module AutosaveAssociation
    extend ActiveSupport::Concern

    # Returns whether or not this record has been changed in any way (including whether
    # any of its nested autosave associations are likewise changed)
    def changed_for_autosave?
      @_changed_for_autosave_called ||= false
      if @_changed_for_autosave_called
        # traversing a cyclic graph of objects; stop it
        result = false
      else
        begin
          @_changed_for_autosave_called = true
          result = new_record? || changed? || marked_for_destruction? || nested_records_changed_for_autosave?
        ensure
          @_changed_for_autosave_called = false
        end
      end
      result
    end
  end
end
