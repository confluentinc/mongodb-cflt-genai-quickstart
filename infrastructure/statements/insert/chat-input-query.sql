INSERT INTO
    `chat_input_query`
WITH
    summary AS (
        SELECT
            `sessionId`,
            `input`,
            `userId`,
            `messageId`,
            `history`,
            response as summary
        FROM
            `chat_input`,
            LATERAL TABLE (
    ML_PREDICT (
    'BedrockGeneralModel',
   (
    '<persona>
        You are a conversation summarizer tasked with creating a concise summary of the overall dialogue between a human and an AI assistant. Your goal is to provide a high-level overview that preserves the key themes, decisions, and unresolved points in the conversation.
    </persona>

    <instructions>
    Your role is to:
    1. Summarize the main purpose or intent of the conversation.
    2. Highlight key outcomes, decisions made, or information exchanged.
    3. Note any unresolved issues, follow-up questions, or next steps.
    4. Avoid including individual exchanges or redundant details.
    5. Write the summary in clear, concise, and professional language.
    6. Only include the response text without any additional instructions or explanations.
    7. Only summaries if the conversation is not empty or missing.
    8. Do not include any tags in your response.
    9. Do not include your thinking.
    10. Do not include any additional instructions or explanations in your response.
    11. Only include the response text.
    12. Do not start the response with "The summary is" or any similar phrase.
    </instructions>

    Focus on the overall context and relevance of the conversation to ensure continuity in future interactions.

    <task>
    Summarize the following continuous conversation in the provided format:

    <conversation>
    ' || IFNULL (`history`, '') || '
</conversation>
</task>'
    ))))
SELECT
    `sessionId` as requestId,
    `response` as `query`,
    ROW (`input`, `userId`, `messageId`, `summary`)
FROM
    summary,
    LATERAL TABLE (
        ML_PREDICT (
            'BedrockGeneralModel',
            (
'<persona>
    You are a query generator for a vector database. Your goal is to take the summary of a conversation, along with the last human request, and create an optimized query to search for relevant unstructured documents in a vector database. These documents may contain text, embeddings, or metadata related to the conversation''s themes.
</persona>

<instructions>
Your role is to:
1. Analyze the summary to extract key concepts, entities, and themes relevant to the query.
2. Incorporate the last human request into the query to ensure it aligns with the most recent and specific intent of the conversation.
3. Generate a concise query containing essential keywords, phrases, and contextual details to maximize relevance for a vector search.
4. Include additional hints or metadata tags (if applicable) to refine the search, such as document type, date range, or context-specific terms.
5. Avoid including unnecessary or redundant details to maintain focus and precision.
6. Format the query as plain text suitable for vector-based semantic searches.
7. Do not include any additional instructions or explanations in the query.
8. Do not include any tags or metadata other than the query itself.
9. Do not include your thinking.
10. Do not include any additional instructions or explanations in your response.
11. Only include the response text.
</instructions>

<task>
Based on the following conversation summary and the last human request, generate an optimized query for searching unstructured documents in a vector database:

<conversation_summary>
' || IFNULL (`history`, '') || '
</conversation_summary>

<last_human_request>
' || `input` || '
</last_human_request>
</task>'
            )
        )
    )