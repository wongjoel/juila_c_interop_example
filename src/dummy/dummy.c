#include <stdlib.h>
#include <stdio.h>
#include "dummy/dummy.h"

int dummy_inc(int x) {
    return x + 1;
}

int dummy_vec_inc(float *vec, int n) {
    // printf("Start in C\n");
    int i;
    for(i=0; i<n; i++) {
        // printf("Loop iteration %d, vec[i]=%f\n", i, vec[i]);
        vec[i] = vec[i] + 1;
        // printf("Loop iteration %d, vec[i]=%f\n", i, vec[i]);
    }    
    return i;
}

dummy_struct* dummy_make_struct(int val1, int val2) {
    dummy_struct *d = malloc(sizeof(*d) + 2 * sizeof(int));
    d->val1 = val1;
    d->val2 = val2;
    d->val3 = 0;
    d->arr_val1[0] = 10;
    d->arr_val1[1] = 11;
    d->arr_val2[0] = 20;
    d->arr_val2[1] = 21;
    d->inner.inner_val1 = 100;
    d->inner.inner_val2 = 200;
    d->variable_array[0] = 30;
    d->variable_array[1] = 31;
    return d;
}

void dummy_use_struct(dummy_struct *d, int val1, int val2) {
    d->val1 = d->val1 + val1;
    d->val2 = d->val2 * val2;
    d->val3 = d->val3 + 1;
    d->arr_val1[0] = d->arr_val1[0]+1;
    d->arr_val1[1] = d->arr_val1[1]+1;
    d->arr_val2[0] = d->arr_val2[0]+2;
    d->arr_val2[1] = d->arr_val2[1]+2;
}

void dummy_delete_struct(dummy_struct *d) {
    free(d);
}