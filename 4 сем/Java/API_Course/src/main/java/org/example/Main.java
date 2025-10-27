package org.example;

import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

public class Main {
    public static final Logger logger = Logger.getLogger(Main.class.getName());

    public static void setLogger(){
        try {
            FileHandler fh = new FileHandler("logs.log", true);
            logger.addHandler(fh);
            SimpleFormatter format = new SimpleFormatter();
            fh.setFormatter(format);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to configure the logging file: ", e);
            System.exit(1);
        }
    }

    public static void main(String[] args) {
        logger.setUseParentHandlers(false);
        setLogger();
        logger.log(Level.INFO, "Starting the program");

        if (args.length < 4) {
            logger.log(Level.SEVERE, "Invalid parameters");
            System.err.println("Usage: -threads=N -timeout=T -services=S1,S2,S3 -format=json/csv");
            System.exit(1);
        }

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

        ThreadManager manager = new ThreadManager(threads, timeout, services, format);
        manager.startPolling();

        try {
            Thread.currentThread().join();
        } catch (InterruptedException e) {
            logger.log(Level.SEVERE, "Thread was interrupted" + e.getMessage());
            System.err.println("Thread was interrupted" + e.getMessage());
            manager.shutdown();
        }
    }
}