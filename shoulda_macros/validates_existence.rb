class Test::Unit::TestCase

  def self.should_require_existence_of(*attributes)
    options = attributes.extract_options!
    options[:message] ||= "does not exist"

    attributes.each do |attribute|
      should "require #{attribute} exists" do
        subject.send("#{attribute}_id=", 0)
        assert !subject.valid?, "#{subject.class} was saved with a non-existent #{attribute}"
        assert subject.errors.on(attribute), "There are no errors on #{attribute} after being set to a non-existent record"
        assert_contains(subject.errors.on(attribute), options[:message], "when set to 0")
      end
    end

    attributes.each do |attribute|
      if options[:allow_nil]
        should "allow #{attribute} to be nil" do
          subject.send("#{attribute}_id=", nil)
          subject.valid?
          assert !subject.errors.on(attribute), "There were errors on #{attribute} after being set to nil"
        end
      else
        should "not allow #{attribute} to be nil" do
          subject.send("#{attribute}_id=", nil)
          assert !subject.valid?, "#{subject.class} was saved with a nil #{attribute}"
          assert subject.errors.on(attribute), "There were errors on #{attribute} after being set to nil"
          assert_contains(subject.errors.on(attribute), options[:message], "when set to nil")
        end
      end
    end
  end

end