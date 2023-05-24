# frozen_string_literal: true

require "faraday"
require "faraday_middleware"

module GooglePalmApi
  class Client
    attr_reader :api_key, :connection

    ENDPOINT_URL = "https://generativelanguage.googleapis.com/"

    DEFAULTS = {
      temperature: 0.0,
      completion_model_name: "text-bison-001",
      chat_completion_model_name: "chat-bison-001",
      embeddings_model_name: "embedding-gecko-001"
    }

    def initialize(api_key:)
      @api_key = api_key
    end

    #
    # The text service is designed for single turn interactions.
    # It's ideal for tasks that can be completed within one response from the API, without the need for a continuous conversation.
    # The text service allows you to obtain text completions, generate summaries, or perform other NLP tasks that don't require back-and-forth interactions.
    # Method signature: https://developers.generativeai.google/api/python/google/generativeai/generate_text
    #
    # @param [String] prompt
    # @param [String] model
    # @param [Float] temperature
    # @param [Integer] candidate_count
    # @param [Integer] max_output_tokens
    # @param [Float] top_p
    # @param [Integer] top_k
    # @param [String] safety_settings
    # @param [Array] stop_sequences
    # @param [String] client
    # @return [Hash]
    #
    def generate_text(
      prompt:,
      temperature: nil,
      candidate_count: nil,
      max_output_tokens: nil,
      top_p: nil,
      top_k: nil,
      safety_settings: nil,
      stop_sequences: nil,
      client: nil
    )
      response = connection.post("/v1beta2/models/#{DEFAULTS[:completion_model_name]}:generateText") do |req|
        req.params = {key: api_key}

        req.body = {prompt: {text: prompt}}
        req.body[:temperature] = temperature || DEFAULTS[:temperature]
        req.body[:candidate_count] = candidate_count if candidate_count
        req.body[:max_output_tokens] = max_output_tokens if max_output_tokens
        req.body[:top_p] = top_p if top_p
        req.body[:top_k] = top_k if top_k
        req.body[:safety_settings] = safety_settings if safety_settings
        req.body[:stop_sequences] = stop_sequences if stop_sequences
        req.body[:client] = client if client
      end
      response.body
    end

    #
    # The chat service is designed for interactive, multi-turn conversations.
    # The service enables you to create applications that engage users in dynamic and context-aware conversations.
    # You can provide a context for the conversation as well as examples of conversation turns for the model to follow.
    # It's ideal for applications that require ongoing communication, such as chatbots, interactive tutors, or customer support assistants.
    # Method signature: https://developers.generativeai.google/api/python/google/generativeai/chat
    #
    # @param [String] prompt
    # @param [String] model
    # @param [String] context
    # @param [Array] examples
    # @param [Array] messages
    # @param [Float] temperature
    # @param [Integer] candidate_count
    # @param [Float] top_p
    # @param [Integer] top_k
    # @param [String] client
    # @return [Hash]
    #
    def generate_chat_message(
      prompt:,
      context: nil,
      examples: nil,
      messages: nil,
      temperature: nil,
      candidate_count: nil,
      top_p: nil,
      top_k: nil,
      client: nil
    )
      # Overwrite the default ENDPOINT_URL for this method.
      response = connection.post("/v1beta2/models/#{DEFAULTS[:chat_completion_model_name]}:generateMessage") do |req|
        req.params = {key: api_key}

        req.body = {prompt: {messages: [{content: prompt}]}}
        req.body[:context] = context if context
        req.body[:examples] = examples if examples
        req.body[:messages] = messages if messages
        req.body[:temperature] = temperature || DEFAULTS[:temperature]
        req.body[:candidate_count] = candidate_count if candidate_count
        req.body[:top_p] = top_p if top_p
        req.body[:top_k] = top_k if top_k
        req.body[:client] = client if client
      end
      response.body
    end

    #
    # The embedding service in the PaLM API generates state-of-the-art embeddings for words, phrases, and sentences.
    # The resulting embeddings can then be used for NLP tasks, such as semantic search, text classification and clustering among many others.
    # This section describes what embeddings are and highlights some key use cases for the embedding service to help you get started.
    # When you're ready to start developing, you can find complete runnable code in the embeddings quickstart.
    # Method signature: https://developers.generativeai.google/api/python/google/generativeai/generate_embeddings
    #
    # @param [String] text
    # @param [String] model
    # @param [String] client
    # @return [Hash]
    #
    def embed(
      text:,
      model: nil,
      client: nil
    )
      response = connection.post("/v1beta2/models/#{model || DEFAULTS[:embeddings_model_name]}:embedText") do |req|
        req.params = {key: api_key}

        req.body = {text: text}
        req.body[:model] = model if model
        req.body[:client] = client if client
      end
      response.body
    end

    #
    # Lists models available through the API.
    #
    # @param [Integer] page_size
    # @param [String] page_token
    # @return [Hash]
    #
    def list_models(page_size: nil, page_token: nil)
      response = connection.get("/v1beta2/models") do |req|
        req.params = {key: api_key}

        req.params[:pageSize] = page_size if page_size
        req.params[:pageToken] = page_token if page_token
      end
      response.body
    end

    #
    # Runs a model's tokenizer on a string and returns the token count.
    #
    # @param [String] model
    # @param [String] prompt
    # @return [Hash]
    #
    def count_message_tokens(model:, prompt:)
      response = connection.post("/v1beta2/models/#{model}:countMessageTokens") do |req|
        req.params = {key: api_key}

        req.body = {prompt: {messages: [{content: prompt}]}}
      end
      response.body
    end

    #
    # Gets information about a specific Model.
    #
    # @param [String] name
    # @return [Hash]
    #
    def get_model(model:)
      response = connection.get("/v1beta2/models/#{model}") do |req|
        req.params = {key: api_key}
      end
      response.body
    end

    private

    # standard:disable Lint/DuplicateMethods
    def connection
      Faraday.new(url: ENDPOINT_URL) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
      end
    end
    # standard:enable Lint/DuplicateMethods
  end
end
