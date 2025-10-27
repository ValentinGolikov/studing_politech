package org.example;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import java.util.logging.Level;

public class NewsApiFetcher implements ApiFetcher {
    private static final String API_URL = "https://newsapi.org/v2/top-headlines?country=us&apiKey=d54065463bcf4734b70e15c99dd7ac28";

    @Override
    public String fetchData() throws Exception {
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet request = new HttpGet(API_URL);
            Main.logger.log(Level.INFO, "HTTP-Get request created");
            try (CloseableHttpResponse response = client.execute(request)) {
                int statusCode = response.getStatusLine().getStatusCode();
                if (statusCode != 200){
                    Main.logger.log(Level.SEVERE, "Bad HTTP Response: Status code " + statusCode);
                    throw new RuntimeException("Bad HTTP Response: Status code " + statusCode);
                }
                else {
                    Main.logger.log(Level.INFO, "Good HTTP Response: Status code " + statusCode);
                    return EntityUtils.toString(response.getEntity());
                }
            }
        }
    }
}