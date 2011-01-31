class Object
  def _?
    self
  end
end

class NilClass
  def _?
    SafeNil.instance
  end
end

class SafeNil
  include Singleton
  undef inspect
  def method_missing(method, *args, &b)
    return nil unless nil.respond_to? method
    nil.send(method, *args, &b) rescue nil
  end
end
