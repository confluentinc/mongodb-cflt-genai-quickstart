INSERT INTO `chat_input_query`
WITH summary AS (
    SELECT `sessionId`, `input`, `userId`, `messageId`, `history`, response as summary
    FROM `chat_input`,
         LATERAL TABLE (
    ML_PREDICT (
    'GeneralModel',
   (
    'You will be provided with a text conversation between a human user and an assistant.\nYour task is to summarize the conversation in a concise paragraph.\n\nThe summary should highlight the following points:\nThe initial greetings.\nThe main topic of the conversation.\nDetails about the product features discussed by the assistant.\nSpecific needs and requests mentioned by the human user, including name, address, and other relevant details if provided.\nDo not include any tags in your response.\nThe conversation is provided below, surrounded by triple quotes:\n“”"\n' || IFNULL(`history`, '') || '\n“”"\n\nPlease generate the summary according to the guidelines above.'
    )
    )
    )
    )
SELECT
    `sessionId` as requestId,
    `response` as `query`,
    ROW(`input`, `userId`, `messageId`, `history`)
FROM
    summary,
    LATERAL TABLE (
                ML_PREDICT (
                    'GeneralModel',
                (
                '
You will be provided with the summary of a conversation between a human user and an assistant as well as the last request made by the human user.

Your task is to generate a concise query that can be used to create an embedding for semantic search. The query should encapsulate the main points from the summary and the essence of the final human request.

Ensure that your response contains only the query without any additional text or tags.

The summary of the conversation is provided below, surrounded by triple quotes:
“”"
' || IFNULL(`history`, '') || '
“”"

The last request made by the human user is provided below, surrounded by triple quotes:
“”"
' || `input` || '
“”"

Generate the query according to the guidelines above.'
                ))
            )