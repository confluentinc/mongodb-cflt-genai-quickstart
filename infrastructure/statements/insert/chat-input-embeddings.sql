insert into `chat_input_embeddings`
select sessionId, embeddings, 5, 5, 0.5, ROW(`input`, `userId`, `messageId`)
from `chat_input`,
     LATERAL TABLE (ML_PREDICT('bedrock_titan_embed', `input`));
