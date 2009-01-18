class Test::Unit::TestCase

  def self.should_require_existence_of(*attrs)
    klass = model_class
    options = attrs.last.is_a?(Hash) ? attrs.pop : {}
    attrs.each do |attribute|
      attribute_instance = Factory(attribute)
      
      should "be valid when #{attribute} exists" do
        @klass = klass.new "#{attribute}_id".to_sym => attribute_instance.id
        @klass.valid?
        assert !@klass.errors.on(attribute)
      end
      
      should "require existence of #{attribute}" do
        @klass = klass.new "#{attribute}_id".to_sym => 0
        assert !@klass.valid?
        assert @klass.errors.on(attribute)
      end
      
      if options[:allow_nil] || options[:allow_blank]
        should "not require existence of #{attribute} if #{attribute}_id is blank" do
          @klass = klass.new "#{attribute}_id".to_sym => nil
          @klass.valid?
          assert !@klass.errors.on(attribute)
        end
      else
        should "require existence of #{attribute} if #{attribute}_id is blank" do
          @klass = klass.new "#{attribute}_id".to_sym => nil
          assert !@klass.valid?
          assert @klass.errors.on(attribute)
        end
      end
      
      attribute_instance.destroy
    end
  end
  
end