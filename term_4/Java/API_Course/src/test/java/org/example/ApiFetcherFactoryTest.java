package org.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class ApiFetcherFactoryTest {

    @Test
    public void testCreateNewsFetcher() {
        ApiFetcher fetcher = ApiFetcherFactory.create("news");
        assertTrue(fetcher instanceof NewsApiFetcher);
    }

    @Test
    public void testCreateWeatherFetcher() {
        ApiFetcher fetcher = ApiFetcherFactory.create("crypto");
        assertTrue(fetcher instanceof CryptoApiFetcher);
    }

    @Test
    public void testCreatePlaceholderFetcher() {
        ApiFetcher fetcher = ApiFetcherFactory.create("weather");
        assertTrue(fetcher instanceof WeatherApiFetcher);
    }

    @Test
    public void testCreateInvalidFetcherThrowsException() {
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                ApiFetcherFactory.create("unknown"));
        assertEquals("Unknown service: unknown", exception.getMessage());
    }
}


//тест полностью покрывает все ветви switch в ApiFetcherFactory.