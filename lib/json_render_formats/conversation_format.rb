class ConversationFormat
  def self.json_partner_lastmsg_count(input)
    input.as_json(include: %i[partner last_message], methods: :messages_count)
  end

  def self.json_partner(input)
    input.as_json(include: :partner)
  end
end
