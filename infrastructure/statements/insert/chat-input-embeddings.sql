insert into `chat_input_embeddings`
select userId, sessionId, messageId, input, embeddings, createdAt
from `chat_input`, LATERAL TABLE (ML_PREDICT('bedrock_titan_embed', input));
