insert into `chat_input_embeddings`
select sessionId, embeddings, 100, 5, 0.0, ROW(`input`, `userId`, `messageId`)
from `chat_input`,
     LATERAL TABLE (ML_PREDICT('bedrock_titan_embed', `input`));
