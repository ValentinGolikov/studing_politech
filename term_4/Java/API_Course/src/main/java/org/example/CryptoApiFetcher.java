package org.example;

import org.apache.http.HttpException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import java.util.logging.Level;

public class CryptoApiFetcher implements ApiFetcher {
    private static String API_URL = "https://api.coinlore.net/api/ticker/?id=90";

    @Override
    public String fetchData() throws Exception {
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet request = new HttpGet(API_URL);
            Main.logger.log(Level.INFO, "HTTP-Get request created");
            try (CloseableHttpResponse response = client.execute(request)) {
                int statusCode = response.getStatusLine().getStatusCode();
                if (statusCode != 200){
                    Main.logger.log(Level.SEVERE, "Bad HTTP Response: Status code " + statusCode);
                    throw new HttpException("Bad HTTP Response: Status code " + statusCode);
                }
                else {
                    Main.logger.log(Level.INFO, "Good HTTP Response: Status code " + statusCode);
                    return EntityUtils.toString(response.getEntity());
                }
            }
        }
    }
}