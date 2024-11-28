INSERT INTO `chat_input_embeddings`
SELECT requestId, embeddings, 100, 5, 0.0, ROW(`input`, `userId`, `messageId`, `history`)
FROM `chat_input_query`,
     LATERAL TABLE (ML_PREDICT('bedrock_titan_embed', query));