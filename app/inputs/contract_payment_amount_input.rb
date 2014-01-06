class ContractPaymentAmountInput < SimpleForm::Inputs::NumericInput
  class FakeBuilder
    def initialize(builder)
      @builder = builder
    end

    def method_missing(*args, &block)
      @builder.public_send(*args, &block)
    end

    def text_field(*args)
      template.text_field_tag(args.first, *args)
    end
  end

  def initialize(*)
    super
    @builder = FakeBuilder.new(@builder)
  end
end
