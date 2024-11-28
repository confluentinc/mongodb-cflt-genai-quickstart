CREATE MODEL BedrockTitanEmbed INPUT (text STRING) OUTPUT (embeddings ARRAY < FLOAT >)
WITH
    (
        'bedrock.connection' = 'bedrock-titan-embed-connection',
        'task' = 'embedding',
        'provider' = 'bedrock'
    );