#include <stdio.h>
#include <stddef.h>
#include <threads.h>

struct Shared {
    int value;
};

int worker(void *vdata) {
    struct Shared * const shared = (struct Shared *)vdata;
    shared->value = shared->value + 1;
    return 0;
}

int main() {
    struct Shared sh = (struct Shared){ .value = 3 };
    thrd_t t;
    if (thrd_success != thrd_create(&t, &worker, &sh))
        return 1;
    thrd_join(t, NULL);

    printf("%d\n", sh.value);

    return 0;
}