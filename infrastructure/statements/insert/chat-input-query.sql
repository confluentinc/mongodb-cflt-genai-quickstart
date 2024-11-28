INSERT INTO `chat_input_query`
SELECT requestId, response, ROW(`input`, `userId`, `messageId`, `history`)
FROM `chat_input_summarized`,
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
            );