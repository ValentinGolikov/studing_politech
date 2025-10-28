package org.example;

import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.*;

class WeatherFetcherTest {

    @Test
    void testFetchDataReturnsNonEmptyString() throws Exception {
        ApiFetcher fetcher = new WeatherApiFetcher();
        String data = fetcher.fetchData();

        assertThat(data)
                .isNotNull()
                .isNotEmpty()
                .contains("[") // API возвращает массив
                .contains("timezone"); // поле из ответа API
    }
}
