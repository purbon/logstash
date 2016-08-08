# encoding: utf-8
require "logstash/namespace"
require "logstash/logging/slow/null_logger"

module LogStash

  class SlowLogBuilder

    def self.build(params={}, klass=LogStash::SlowLog)
      return LogStash::NullLog.new unless params.fetch(:enabled, true)
      slowlog_path = ""
      if !params[:base_dir].nil?
        log_file = params[:log_file] || klass.log_file
        slowlog_path = File.join(params[:base_dir], log_file)
      end
      params[:path] = slowlog_path
      return klass.new(params)
    end
  end

  class SlowLog

    def initialize(params={})
      @path   = params.fetch(:path, "")
      logger_init(@path)
    end

    def log(*args)
      logger.warn(*args)
    end
    alias_method :warn, :log

    def close
      @log_file.close if @log_file
    end

    def logger
      @logger ||= configure_logger
    end

    def configure_logger(logger=nil)
      logger       = logger.nil? ? Cabin::Channel.get(LogStash::SlowLog) : logger
      logger.level = :warn
      logger
    end

    private

    def logger_init(path)
      if !path.empty?
        @log_file     = ::File.new(path, "a")
        subscribe_inputstream(@log_file)
      end
      subscribe_inputstream(STDOUT)
    end

    def subscribe_inputstream(input_stream)
      logger.subscribe(LogStash::Logging::JSON.new(input_stream))
    end
  end

  class PluginsSlowLog < SlowLog
    def configure_logger(logger=nil)
      logger       = logger.nil? ? Cabin::Channel.get(LogStash::PluginsSlowLog) : logger
      logger.level = :warn
      logger
    end

    def self.log_file
      "pipelines-slow.log"
    end
  end

  class PipelineSlowLog < SlowLog
    def configure_logger(logger=nil)
      logger       = logger.nil? ? Cabin::Channel.get(LogStash::PipelineSlowLog) : logger
      logger.level = :warn
      logger
    end

    def self.log_file
      "plugins-slow.log"
    end
  end
end
