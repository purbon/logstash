# encoding: utf-8
require "logstash/namespace"

module LogStash
  class NullLog

    def log(*args)
    end
    alias_method :warn, :log

    def close
    end

  end
end
