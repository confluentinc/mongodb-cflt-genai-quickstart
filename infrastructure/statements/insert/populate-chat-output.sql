INSERT INTO
    chat_output
SELECT
    requestId AS sessionId,
    metadata.userId AS userId,
    response AS output
FROM
    `chat_input_with_products` /*+ OPTIONS('scan.startup.mode'='latest-offset') */,
    LATERAL TABLE (
        ML_PREDICT (
            'ColinAiChatAssistant',
            (
                'Big Friendly Bank offers these financial products:\n' || `product_summaries` || '\nThe human name is ' || `metadata`.`userId` || '\nCurrent user-assistant conversation:<start>' || `metadata`.`input` || '<end>\Colin reply:'
            )
        )
    );