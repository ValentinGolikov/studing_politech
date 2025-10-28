package org.example;

import org.junit.jupiter.api.Test;
import java.util.concurrent.atomic.AtomicBoolean;

import static org.assertj.core.api.Assertions.*;

class ThreadManagerTest {

    @Test
    void testStartPollingAndShutdown() throws InterruptedException {
        String[] services = {"crypto"};
        ThreadManager manager = new ThreadManager(1, 1, services, "json");

        AtomicBoolean shutdownCalled = new AtomicBoolean(false);

        Thread managerThread = new Thread(() -> {
            manager.startPolling();

            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }

            manager.shutdown();
            shutdownCalled.set(true);
        });

        managerThread.start();
        managerThread.join(3000);

        assertThat(shutdownCalled.get()).isTrue();
        assertThat(manager.isRunning()).isFalse();
    }

    @Test
    void testMultipleStartPollingCalls() {
        String[] services = {"crypto"};
        ThreadManager manager = new ThreadManager(1, 1, services, "json");

        manager.startPolling();
        manager.startPolling(); // Должно просто вывести ошибку

        assertThat(manager.isRunning()).isTrue();

        manager.shutdown();
    }
}
