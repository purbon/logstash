# encoding: utf-8
require "spec_helper"
require "logstash/logging/slow_log"
require "tmpdir"

describe LogStash::SlowLog do

  context "when configured by default" do

    it "should use the warn log level" do
      expect(subject.logger).to receive(:warn).with("foo")
      subject.log("foo")
    end

    it "should output to STDOUT" do
      expect_any_instance_of(described_class).to receive(:subscribe_inputstream).with(STDOUT)
      expect_any_instance_of(described_class).not_to receive(:subscribe_inputstream).with(kind_of(::File))
      described_class.new
    end
  end

  context "when a file is setup" do

    it "should output to STDOUT and File" do
      expect_any_instance_of(described_class).to receive(:subscribe_inputstream).with(STDOUT)
      expect_any_instance_of(described_class).to receive(:subscribe_inputstream).with(kind_of(::File))
      described_class.new(:path => File.join(Dir.tmpdir, "foo.log"))
    end
  end
end
