# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/zookeeper"
require "logstash/codecs/plain"
require "logstash/event"

describe "outputs/zookeeper" do
  let(:event) { LogStash::Event.new({'message' => 'hello'}) }
  let(:output) { LogStash::Outputs::Zookeeper.new }

  context 'when initializing' do
	  it "should raise a exception" do
		  output = LogStash::Plugin.lookup("output", "zookeeper").new()
		  expect {output.register}.to raise_error
	  end

	  it "should register" do
		  output = LogStash::Plugin.lookup("output", "zookeeper").new()
		  output.ip_list = "10.123.81.11:2181,10.123.81.12:2181,10.123.81.13:2181"
		  expect {output.register}.to_not raise_error
	  end
	  
	  it 'should populate zookeeper config with default values' do
		  zookeeper = LogStash::Outputs::Zookeeper.new()
		  insist {zookeeper.ip_list} == 'localhost:2181'
		  insist {zookeeper.path} == '/logstash'
	  end
  end

  context 'when outputting messages' do
	  it 'should send message to zookeeper permanent znode' do
		  zookeeper = LogStash::Outputs::Zookeeper.new()
		  zookeeper.ip_list = "10.123.81.11:2181,10.123.81.12:2181,10.123.81.13:2181"
		  zookeeper.register
		  zookeeper.receive(event)
	  end

	  it 'should send message to zookeeper ephemeral znode' do
		  zookeeper = LogStash::Outputs::Zookeeper.new()
		  zookeeper.ip_list = "10.123.81.11:2181,10.123.81.12:2181,10.123.81.13:2181"
		  zookeeper.path = "/tmp"
		  zookeeper.ephemeral = true
		  zookeeper.register
		  zookeeper.receive(event)
	  end
  end
end
