package io.confluent.pie.search.tools;

import java.util.function.Supplier;

/**
 * Provides support for lazy initialization.
 *
 * @param <T> The type of object that is being lazily initialized.
 */
public class Lazy<T> implements Supplier<T> {
    private T instance;
    private final Supplier<T> supplier;

    public Lazy(Supplier<T> supplier) {
        this.supplier = supplier;
    }

    public synchronized T get() {
        if (instance == null) {
            instance = supplier.get();
        }

        return instance;
    }

}
