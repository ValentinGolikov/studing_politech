package org.example;

import org.apache.http.HttpException;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class NewsApiFetcherTest {

    @Test
    void testFetchDataReturnsJson() throws Exception {
        NewsApiFetcher fetcher = new NewsApiFetcher();
        String data = fetcher.fetchData();

        assertThat(data).isNotBlank();
        assertThat(data).contains("articles"); // ожидаем ключ
    }
}
