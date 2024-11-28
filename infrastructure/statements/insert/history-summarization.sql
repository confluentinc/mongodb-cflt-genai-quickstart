INSERT INTO
    chat_input_summarized
SELECT
    sessionId,
    ROW(`input`, `userId`, `messageId`, IF (history <> '', response, ''))
FROM
    `chat_input`,
    LATERAL TABLE (
        ML_PREDICT (
            'GeneralModel',
            (
                'You will be provided with a text conversation between a human user and an assistant.\nYour task is to summarize the conversation in a concise paragraph.\n\nThe summary should highlight the following points:\nThe initial greetings.\nThe main topic of the conversation.\nDetails about the product features discussed by the assistant.\nSpecific needs and requests mentioned by the human user, including name, address, and other relevant details if provided.\nDo not include any tags in your response.\nThe conversation is provided below, surrounded by triple quotes:\n“”"\n' || IFNULL(`history`, '') || '\n“”"\n\nPlease generate the summary according to the guidelines above.'
            )
        )
    );