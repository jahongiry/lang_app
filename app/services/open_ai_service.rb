class OpenAIService
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def initialize(api_key)
    @options = {
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      }
    }
  end

  def evaluate_english(text)
    body = {
      model: "gpt-3.5-turbo",
      messages: [
        { role: "user", content: "Evaluate the following English text for grammar and vocabulary: '#{text}'" }
      ],
      max_tokens: 150
    }.to_json

    response = self.class.post("/chat/completions", body: body, **@options)
    if response.success?
      response.parsed_response
    else
      Rails.logger.error "OpenAI API Error: #{response.code} - #{response.body}"
      nil
    end
  end
end
