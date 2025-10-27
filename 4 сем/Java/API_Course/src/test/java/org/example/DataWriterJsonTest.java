package org.example;

import org.junit.jupiter.api.Test;

import java.io.File;
import java.nio.file.Files;

import static org.junit.jupiter.api.Assertions.*;

public class DataWriterJsonTest {

    @Test
    public void testWriteJson() throws Exception {
        String sampleJson = """
            {
              "items": [
                {"id": 1456, "name": "Alice in Wonderland", "author": "Lewis Carroll"},
                {"id": 345, "name": "War and Peace", "author": "Leo Tolstoy"}
              ]
            }
            """;

        DataWriter.write(sampleJson, "json");

        File file = new File("output.json");
        assertTrue(file.exists(), "output.json should be created");

        String content = Files.readString(file.toPath());

        assertTrue(content.trim().startsWith("["), "JSON should ne array");
        assertTrue(content.contains("\"id\" : 1456"), "should contain id = 1456");
        assertTrue(content.contains("\"name\" : \"Alice in Wonderland\""), "should contain 'Alice in Wonderland'");
        assertTrue(content.contains("\"author\" : \"Lewis Carroll\""), "should contain 'Lewis Carroll'");
        assertTrue(content.contains("\"id\" : 345"), "should contain id = 345");
        assertTrue(content.contains("\"name\" : \"War and Peace\""), "should contain 'War and Peace'");
        assertTrue(content.contains("\"author\" : \"Leo Tolstoy\""), "should contain 'Leo Tolstoy'");
    }
}

// mvn -Dtest=DataWriterJsonTest test для вывода этого теста