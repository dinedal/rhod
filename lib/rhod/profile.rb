class Rhod::Profile
  ATTRS = %i.name retries backoffs fallback pool exceptions.
  attr_accessor(*ATTRS)

  @@profiles = {}

  def initialize(options={})
    # When creating new profiles, copy from the global default, incase it was customized.
    # but don't copy :name, so mapping to profile names is not overwritten unless it's explict
    if defined?(Rhod::Profile::DEFAULT)
      ATTRS.each do |attr|
        self[attr] = Rhod::Profile::DEFAULT[attr] unless attr == :name
      end
    end

    ATTRS.each do |attr|
      self[attr] = options[attr] if options[attr]
    end

    # Syntax sugar: named .with_#{profile} methods on this class and the module
    if options[:name]
      @@profiles[options[:name]] = self

      self.class.__send__(:define_method, :"with_#{options[:name]}") do |*args, &block|
        Rhod::Command.execute(*args, @@profiles[options[:name]], &block)
      end

      Rhod.class.__send__(:define_method, :"with_#{options[:name]}") do |*args, &block|
        Rhod::Command.execute(*args, @@profiles[options[:name]], &block)
      end
    end

    self
  end

  # Syntax sugar: allow for array type accessors to profile attributes
  def [](attr)
    self.__send__(:"#{attr}")
  end

  def []=(attr, val)
    self.__send__(:"#{attr}=", val)
  end

end

Rhod::Profile::DEFAULT = Rhod::Profile.new({
    name: :default,
    retries: 0,
    backoffs: Rhod::Backoffs::Logarithmic.new(1.3),
    fallback: nil,
    pool: ConnectionPool.new(size: 1, timeout: 0) { nil },
    exceptions: [Exception, StandardError],
  })
