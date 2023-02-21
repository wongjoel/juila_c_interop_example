#ifndef _DUMMY_H_
#define _DUMMY_H_

typedef struct {
	int inner_val1;
	int inner_val2;
} inner_struct;

typedef struct {
	int val1;
	int val2;
    int val3;
	int arr_val1[2];
	int arr_val2[2];
	inner_struct inner;
	int variable_array[];
} dummy_struct;

extern int dummy_inc(int x);
extern int dummy_vec_inc(float *vec, int n);

extern dummy_struct* dummy_make_struct(int val1, int val2);
extern void dummy_use_struct(dummy_struct *d, int val1, int val2);
extern void dummy_delete_struct(dummy_struct *d);

#endif