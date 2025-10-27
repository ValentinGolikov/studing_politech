package org.example;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;

public class ThreadManager {
    private final ExecutorService executor;
    private final ScheduledExecutorService timeoutScheduler;
    private final int timeoutSec;
    private final String[] services;
    private final String format;
    private volatile boolean isRunning;
    private final AtomicInteger currentServiceIndex = new AtomicInteger(0);

    public ThreadManager(int threads, int timeoutSec, String[] services, String format) {
        this.executor = Executors.newFixedThreadPool(threads);
        this.timeoutScheduler = Executors.newScheduledThreadPool(threads);
        this.timeoutSec = timeoutSec;
        this.services = services;
        this.format = format;
        this.isRunning = false;
    }

    public synchronized boolean isRunning() {
        return isRunning;
    }

    public void startPolling() {
        if (isRunning) {
            Main.logger.log(Level.WARNING, "Attempt to rerun polling");
            System.err.println("ThreadManager is already running");
            return;
        }

        isRunning = true;
        String text = String.format("Starting polling for %d services with %d threads%n",
                services.length, ((ThreadPoolExecutor)executor).getMaximumPoolSize());
        Main.logger.log(Level.INFO, text);
        System.out.printf(text);

        for (int i = 0; i < ((ThreadPoolExecutor)executor).getMaximumPoolSize(); i++) {
            executor.submit(() -> {
                while (isRunning && !Thread.currentThread().isInterrupted()) {
                    try {
                        int index = currentServiceIndex.getAndUpdate(
                                prev -> (prev + 1) % services.length
                        );
                        String service = services[index];

                        ApiFetcher fetcher = ApiFetcherFactory.create(service);
                        String data = fetcher.fetchData();
                        DataWriter.write(data, format);
                        Main.logger.log(Level.INFO, String.format("Successfully fetched data from %s%n", service));
                        System.out.printf("Successfully fetched data from %s%n", service);

                        timeoutScheduler.schedule(() -> {}, timeoutSec, TimeUnit.SECONDS).get();

                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        Main.logger.log(Level.INFO, "Thread interrupted");
                        System.out.println("Thread interrupted");
                    } catch (Exception e) {
                        Main.logger.log(Level.WARNING, String.format("Error: %s%n", e.getMessage()));
                        System.err.printf("Error: %s%n", e.getMessage());
                    }
                }
            });
        }
    }

    public void shutdown() {
        isRunning = false;
        executor.shutdownNow();
        timeoutScheduler.shutdownNow();
        try {
            if (!executor.awaitTermination(5, TimeUnit.SECONDS)) {
                Main.logger.log(Level.WARNING, "Executor did not terminate in the specified time");
                System.err.println("Executor did not terminate in the specified time");
            }
            if (!timeoutScheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                Main.logger.log(Level.WARNING, "Timeout scheduler did not terminate in the specified time");
                System.err.println("Timeout scheduler did not terminate in the specified time");
            }
        } catch (InterruptedException e) {
            Main.logger.log(Level.WARNING, "Interrupted while waiting for executor to terminate");
            System.err.println("Interrupted while waiting for executor to terminate");
            Thread.currentThread().interrupt();
        }
        Main.logger.log(Level.INFO, "ThreadManager shutdown completed");
        System.out.println("ThreadManager shutdown completed");
    }
}