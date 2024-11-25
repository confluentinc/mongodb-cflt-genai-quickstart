package io.confluent.pie.search.tools;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.pie.search.models.AWSSecret;
import io.confluent.pie.search.models.Credentials;
import lombok.extern.slf4j.Slf4j;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Utility class for getting secrets from the secrets extension
 */
@Slf4j
public class SecretsUtils {

    /**
     * Get the secret value for the given secret name
     *
     * @param secretName secret name
     * @return secret value
     * @throws IOException if an error occurs
     */
    public static Credentials getCredentials(String secretName) throws IOException {
        if (secretName == null || secretName.isEmpty()) {
            log.info("No secret name provided");
            return null;
        }

        final String urlEncodedSecretName = secretName.replace("/", "%2F");
        log.info("Getting secret value for secret: {}", urlEncodedSecretName);

        final String secrets_extension_http_port = System.getenv("PARAMETERS_SECRETS_EXTENSION_HTTP_PORT");
        final String secretURL = "http://localhost:" + ((secrets_extension_http_port == null) ? "2773" : secrets_extension_http_port) + "/secretsmanager/get?secretId=" + urlEncodedSecretName;

        log.info("Secret URL: {}", secretURL);

        HttpURLConnection con = null;
        try {
            // Call the secrets extension to get the secret value
            con = (HttpURLConnection) new URL(secretURL).openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("X-Aws-Parameters-Secrets-Token", System.getenv("AWS_SESSION_TOKEN"));

            // Check the response code
            final int status = con.getResponseCode();
            if (status != 200) {
                log.error("Error getting secret value: {}", status);
                throw new RuntimeException("Error getting secret value: " + status);
            }

            // Read the response
            StringBuilder content = new StringBuilder();
            try (BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()))) {
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine);
                }
            }

            // Parse the secret value
            final AWSSecret secret = new ObjectMapper().readValue(content.toString(), AWSSecret.class);
            return new ObjectMapper().readValue(secret.SecretString(), Credentials.class);
        } finally {
            if (con != null) {
                con.disconnect();
            }
        }
    }
}
