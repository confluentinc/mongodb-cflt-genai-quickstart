CREATE MODEL BedrockGeneralModel INPUT (text STRING) OUTPUT (response STRING) COMMENT 'General model with no system prompt.'
WITH
    (
        'task' = 'text_generation',
        'provider' = 'bedrock',
        'bedrock.PARAMS.max_tokens' = '200000',
        'bedrock.PARAMS.temperature' = '0.1',
        'bedrock.connection' = 'bedrock-claude-3-haiku-connection',
        'bedrock.client_timeout' = '120',
        'bedrock.system_prompt' = ''
    );