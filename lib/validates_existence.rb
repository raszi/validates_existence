module ActiveRecord
  module Validations

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      
      # The validates_existence_of validator checks that a foreign key in a belongs_to
      # association points to an exisiting record. If :allow_nil => true, then the key
      # itself may be nil. A non-nil key requires that the foreign object must exist.
      # Works with polymorphic belongs_to.
      def validates_existence_of(*attr_names)
        opts = { :message => :non_existent, :on => :save }
        opts.update(attr_names.extract_options!)

        send(validation_method(opts[:on]), opts) do |record|
          attr_names.each do |attr_name|
            attr_name = attr_name.to_s.sub(/_id$/, '').to_sym

            unless (assoc = reflect_on_association(attr_name)) && assoc.macro == :belongs_to
              raise ArgumentError, "Cannot validate existence of :#{attr_name} because it is not a belongs_to association."
            end

            attr_key = assoc.primary_key_name.to_sym
            fk_value = record.send(attr_key)

            next if fk_value.nil? && opts[:allow_nil] || fk_value.blank? && opts[:allow_blank]

            if fk_value.nil?
              associated_object = record.send(attr_name)
              next if !associated_object.nil? && (associated_object.new_record? || associated_object.id)
            end

            if foreign_type = assoc.options[:foreign_type] # polymorphic
              foreign_type_value = record[assoc.options[:foreign_type]]
              if foreign_type_value.blank?
                record.errors.add(attr_name, :does_not_exist, :default => opts[:message])
                next
              else
                assoc_class = foreign_type_value.constantize
              end
            else # not polymorphic
              assoc_class = assoc.klass
            end

            record.errors.add(attr_name, :does_not_exist, :default => opts[:message]) unless assoc_class && assoc_class.exists?(fk_value)
          end
        end
      end

    end # ClassMethods

  end
end
