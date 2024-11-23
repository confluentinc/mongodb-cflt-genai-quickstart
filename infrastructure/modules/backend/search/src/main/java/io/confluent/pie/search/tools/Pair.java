package io.confluent.pie.search.tools;

import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.experimental.FieldDefaults;

@EqualsAndHashCode
@Getter
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class Pair<L, R> {

    L left;
    R right;

    protected Pair(L left, R right) {
        this.left = left;
        this.right = right;
    }

    public static <L, R> Pair<L, R> of(L left, R right) {
        return new Pair<>(left, right);
    }
}