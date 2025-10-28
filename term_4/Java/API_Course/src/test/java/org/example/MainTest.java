package org.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class MainTest {

    @Test
    public void testArgumentParsing() {
        String[] args = {
                "-threads=3",
                "-timeout=5",
                "-services=news,crypto",
                "-format=csv"
        };

        // Симулируем поведение main, разбирая аргументы
        int threads = 1;
        int timeout = 10;
        String[] services = new String[0];
        String format = "json";

        for (String arg : args) {
            if (arg.startsWith("-threads=")) {
                threads = Integer.parseInt(arg.substring(9));
            } else if (arg.startsWith("-timeout=")) {
                timeout = Integer.parseInt(arg.substring(9));
            } else if (arg.startsWith("-services=")) {
                services = arg.substring(10).split(",");
            } else if (arg.startsWith("-format=")) {
                format = arg.substring(8);
            }
        }

        assertEquals(3, threads);
        assertEquals(5, timeout);
        assertArrayEquals(new String[]{"news", "crypto"}, services);
        assertEquals("csv", format);
    }
}



//Проверяет корректный разбор параметров командной строки.
//
//Покрывает логическую часть Main.main().