CREATE
MODEL bedrock_titan_embed
INPUT (text STRING)
OUTPUT (embeddings ARRAY<FLOAT>)
WITH ( 'bedrock.connection' ='bedrock-titan-embed-connection', 'task'='embedding','provider'='bedrock');