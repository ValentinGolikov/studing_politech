package org.example;

public class ApiFetcherFactory {
    public static ApiFetcher create(String serviceName) {
        return switch (serviceName.toLowerCase()) {
            case "news" -> new NewsApiFetcher();
            case "crypto" -> new CryptoApiFetcher();
            case "weather" -> new WeatherApiFetcher();
            default -> throw new IllegalArgumentException("Unknown service: " + serviceName);
        };
    }
}