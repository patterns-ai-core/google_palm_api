# frozen_string_literal: true

require "cohere"

RSpec.describe GooglePalmApi::Client do
  subject { described_class.new(api_key: "123") }

  describe "#list_models" do
    let(:fixture) { JSON.parse(File.read("spec/fixtures/list_models.json")) }
    let(:response) { OpenStruct.new(body: fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("/v1beta2/models")
        .and_return(response)
    end

    it "returns a list of models" do
      expect(subject.list_models.dig("models").count).to eq(3)
    end
  end

  describe "#get_model" do
    let(:fixture) { JSON.parse(File.read("spec/fixtures/list_models.json")).dig("models").first }
    let(:response) { OpenStruct.new(body: fixture) }
    let(:model) { "chat-bison-001" }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("/v1beta2/models/#{model}")
        .and_return(response)
    end

    it "returns the model" do
      expect(subject.get_model(model: model)).to eq(fixture)
    end
  end

  describe "#count_message_tokens" do
    let(:response) { OpenStruct.new(body: {"tokenCount" => 14}) }
    let(:model) { "chat-bison-001" }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("/v1beta2/models/#{model}:countMessageTokens")
        .and_return(response)
    end

    it "returns the token count" do
      expect(subject.count_message_tokens(model: model, prompt: "Hello")).to eq(response.body)
    end
  end

  describe "#embed" do
    let(:response) { OpenStruct.new(body: {"embedding" => {"value" => [0.0071609155, 0.010057832, -0.016587045]}}) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("/v1beta2/models/embedding-gecko-001:embedText")
        .and_return(response)
    end

    it "returns the embedding" do
      expect(subject.embed(text: "Hello world!")).to eq(response.body)
    end
  end

  describe "#generate_text" do
    let(:fixture) { JSON.parse(File.read("spec/fixtures/generate_text.json")) }
    let(:response) { OpenStruct.new(body: fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("/v1beta2/models/text-bison-001:generateText")
        .and_return(response)
    end

    it "returns the generated text" do
      expect(subject.generate_text(prompt: "Hello")).to eq(fixture)
    end
  end

  describe "#generate_chat_message" do
    let(:fixture) { JSON.parse(File.read("spec/fixtures/generate_chat_message.json")) }
    let(:response) { OpenStruct.new(body: fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("/v1beta2/models/chat-bison-001:generateMessage")
        .and_return(response)
    end

    it "returns the generated text" do
      expect(subject.generate_chat_message(prompt: "Hello!")).to eq(fixture)
    end
  end
end
