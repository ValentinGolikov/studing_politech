package org.example;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import java.util.logging.Level;

public class WeatherApiFetcher implements ApiFetcher {
    private static final String API_URL = "https://api.weatherbit.io/v2.0/current?lat=35.7796&lon=-78.6382&key=0b9b88701c6844838c6aefc484dc8c42&station=UUEE";

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