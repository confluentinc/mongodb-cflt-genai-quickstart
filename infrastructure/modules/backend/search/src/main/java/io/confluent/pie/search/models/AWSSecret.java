package io.confluent.pie.search.models;

import java.util.Map;

/**
 * AWS Secret
 *
 * @param ARN            AWS ARN
 * @param CreatedDate    Date created
 * @param Name           Secret name
 * @param SecretBinary   Secret binary
 * @param SecretString   Secret string
 * @param VersionId      Version ID
 * @param VersionStages  Version stages
 * @param ResultMetadata Result metadata
 */
public record AWSSecret(String ARN, String CreatedDate, String Name, byte[] SecretBinary, String SecretString,
                        String VersionId, String[] VersionStages, Map<String, Object> ResultMetadata) {
}
