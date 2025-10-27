package org.example;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;

public class DataWriter {
    private static final ObjectMapper jsonMapper = new ObjectMapper();
    private static final CsvMapper csvMapper = new CsvMapper();
    private static final ReentrantLock dataLock = new ReentrantLock();
    private static final ArrayNode jsonDataCache = jsonMapper.createArrayNode();
    private static final List<Map<String, String>> csvDataCache = new ArrayList<>();

    public static void write(String data, String format) throws IOException {
        dataLock.lock();
        try {
            String fileName = "output." + format;
            Main.logger.log(Level.INFO, "Processing data for " + fileName);
            System.out.println("Processing data for " + fileName);

            JsonNode rootNode = jsonMapper.readTree(data);
            JsonNode dataNode = findDataNode(rootNode);

            if (dataNode == null || dataNode.isEmpty()) {
                throw new IOException("No valid data found in API response");
            }

            if (format.equalsIgnoreCase("json")) {
                writeJson(dataNode, fileName);
            } else if (format.equalsIgnoreCase("csv")) {
                writeCsv(dataNode, fileName);
            }
        } finally {
            dataLock.unlock();
        }
    }

    private static JsonNode findDataNode(JsonNode rootNode) {
        // Если корневой узел уже массив - возвращаем его
        if (rootNode.isArray()) {
            Main.logger.log(Level.INFO, "Root node is an array");
            System.out.println("Root node is an array");
            return rootNode;
        }
        // Ищем первый массив в структуре JSON
        return findFirstArrayNode(rootNode);
    }

    private static JsonNode findFirstArrayNode(JsonNode node) {
        if (node.isArray()) {
            return node;
        }

        if (node.isObject()) {
            Iterator<Map.Entry<String, JsonNode>> fields = node.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> entry = fields.next();
                JsonNode arrayNode = findFirstArrayNode(entry.getValue());
                if (arrayNode != null && arrayNode.isArray()) {
                    Main.logger.log(Level.INFO, "Found data array in field: " + entry.getKey());
                    System.out.println("Found data array in field: " + entry.getKey());
                    return arrayNode;
                }
            }
        }

        return null;
    }

    private static void writeJson(JsonNode newData, String fileName) throws IOException {
        if (newData.isArray()) {
            jsonDataCache.addAll((ArrayNode) newData);
        } else {
            jsonDataCache.add(newData);
        }

        jsonMapper.writerWithDefaultPrettyPrinter()
                .writeValue(new File(fileName), jsonDataCache);

        Main.logger.log(Level.INFO, "JSON data appended successfully. Total items: " + jsonDataCache.size());
        System.out.println("JSON data appended successfully. Total items: " + jsonDataCache.size());
    }

    private static void writeCsv(JsonNode dataNode, String fileName) throws IOException {
        List<Map<String, String>> newData = flattenData(dataNode);
        csvDataCache.addAll(newData);

        // Создаем схему на основе всех накопленных данных
        Set<String> allColumns = new LinkedHashSet<>();
        csvDataCache.forEach(record -> allColumns.addAll(record.keySet()));

        CsvSchema.Builder schemaBuilder = CsvSchema.builder();
        allColumns.forEach(schemaBuilder::addColumn);
        CsvSchema schema = schemaBuilder.build().withHeader();

        csvMapper.writerFor(List.class)
                .with(schema)
                .writeValue(new File(fileName), csvDataCache);

        Main.logger.log(Level.INFO, "CSV updated successfully with " + csvDataCache.size() + " total records");
        System.out.println("CSV updated successfully with " + csvDataCache.size() + " total records");
    }

    private static List<Map<String, String>> flattenData(JsonNode dataNode) {
        List<Map<String, String>> flatData = new ArrayList<>();

        if (dataNode.isArray()) {
            for (JsonNode item : dataNode) {
                flatData.add(flattenObject(item));
            }
        } else {
            flatData.add(flattenObject(dataNode));
        }

        return flatData;
    }

    private static Map<String, String> flattenObject(JsonNode node) {
        Map<String, String> flatMap = new LinkedHashMap<>();
        node.fields().forEachRemaining(field -> {
            String key = field.getKey();
            JsonNode value = field.getValue();

            if (value.isObject()) {
                flattenNestedObject(key, value, flatMap);
            } else {
                flatMap.put(key, value.asText());
            }
        });
        return flatMap;
    }

    private static void flattenNestedObject(String prefix, JsonNode node, Map<String, String> flatMap) {
        node.fields().forEachRemaining(field -> {
            String key = prefix + "_" + field.getKey();
            JsonNode value = field.getValue();

            if (value.isObject()) {
                flattenNestedObject(key, value, flatMap);
            } else {
                flatMap.put(key, value.asText());
            }
        });
    }
}