package org.example;

import org.apache.http.HttpException;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CryptoApiFetcherTest {

    @Test
    void testFetchDataReturnsNonEmptyString() throws Exception {
        ApiFetcher fetcher = new CryptoApiFetcher();
        String data = fetcher.fetchData();

        assertThat(data)
                .isNotNull()
                .isNotEmpty()
                .contains("[") // предполагаем, что API возвращает JSON-массив
                .contains("name"); // типичное поле в ответе
    }
}
