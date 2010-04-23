module Algo
  module MacroSpecs
    def should_require_numeric(instance_var, *args)
      args.each do |arg|
        it "should require #{arg} to be numeric" do
          instance_variable_get(instance_var).send("#{arg}=", "abcd")
          instance_variable_get(instance_var).should_not be_valid
        end
      end
    end
  end
end

