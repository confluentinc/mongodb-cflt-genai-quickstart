package org.confluent.pie.search.services;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.confluent.pie.search.models.Credentials;
import org.confluent.pie.search.tools.SecretsUtils;

import java.io.IOException;

@Getter
@AllArgsConstructor
public class SearchRequestDeserializerConfiguration {

    private final String srURL;
    private final Credentials srCredentials;

    public SearchRequestDeserializerConfiguration() throws IOException {
        srURL = System.getenv("SR_URL");
        srCredentials = SecretsUtils.getCredentials(System.getenv("SR_SECRET"));
    }

}
