class MassObject
 
  def self.set_attrs(*attributes)
    @attributes = attributes

    # rewriting attr_accessor *attributes
    attributes.each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}".to_sym)
      end

      define_method("#{attribute}=") do |value|
        instance_variable_set("@#{attribute}".to_sym, value)
      end
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |row| new(row) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end