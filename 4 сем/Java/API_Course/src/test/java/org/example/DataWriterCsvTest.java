package org.example;

import org.junit.jupiter.api.Test;

import java.io.File;
import java.nio.file.Files;

import static org.junit.jupiter.api.Assertions.*;

public class DataWriterCsvTest {

    @Test
    public void testWriteCsv() throws Exception {
        String sampleJson = """
            {
              "items": [
                {"id": 1456, "name": "Alice in Wonderland", "author": "Lewis Carroll"},
                {"id": 345, "name": "War and Peace", "author": "Leo Tolstoy"}
              ]
            }
            """;

        DataWriter.write(sampleJson, "csv");

        File file = new File("output.csv");
        assertTrue(file.exists(), "output.csv should be created");

        String content = Files.readString(file.toPath());
        assertTrue(content.contains("Alice in Wonderland"), "CSV should contain 'Alice in Wonderland'");
        assertTrue(content.contains("Lewis Carroll"), "CSV should contain 'Lewis Carroll'");
        assertTrue(content.contains("War and Peace"), "CSV should contain 'War and Peace'");
        assertTrue(content.contains("Leo Tolstoy"), "CSV should contain 'Leo Tolstoy'");
        assertTrue(content.contains("id,name,author"), "CSV should contain header line");
    }
}
