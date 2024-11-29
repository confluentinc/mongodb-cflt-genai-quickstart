INSERT INTO
    `chat_input_embeddings`
SELECT
    requestId,
    embeddings,
    100,
    5,
    0.4,
    ROW (`input`, `userId`, `messageId`, `history`)
FROM
    `chat_input_query`,
    LATERAL TABLE (ML_PREDICT ('BedrockTitanEmbed', query));