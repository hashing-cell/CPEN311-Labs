#include <stdio.h>
#include <stdlib.h>

/* normally these would be contiguous but it's nice to know where they are for debugging */
int *nn;
int *input;
int *l1_acts;
int *l2_acts;
int *l3_acts;

#define L1_IN  784
#define L1_OUT 1000
#define L2_IN L1_OUT
#define L2_OUT 1000
#define L3_IN L2_OUT
#define L3_OUT 10
#define NPARAMS (L1_OUT + L1_IN * L1_OUT + L2_OUT + L2_IN * L2_OUT + L3_OUT + L3_IN * L3_OUT)


FILE *output_file;

// use software to compute the dot product of w[i]*ifmap[i]
int dotprod_sw(int n_in, int *w, int *ifmap)
{
        int sum = 0;
        for (unsigned i = 0; i < n_in; ++i) { /* Q16 dot product */
            sum += (int) (((long long) w[i] * (long long) ifmap[i]) >> 16);
            fprintf(stdout, "Dot w %d: %lx\n", i,(int) w[i]);
            fprintf(stdout, "Dot if %d: %lx\n", i,(int) ifmap[i]);
            fprintf(stdout, "Dot comp %d: %lx\n", i, (((long long) w[i] * (long long) ifmap[i])));
            fprintf(stdout, "Dot %d: %lx\n", i, (((long long) w[i] * (long long) ifmap[i]) >> 16));
            fprintf(stdout, "Sum %d: %lx\n", i, sum);
            fprintf(stdout, "\n");
        }
        return sum;
}



// ----------------------------------------------------------------

// BASELINE, TASK6 and TASK7:  compute dot products
// optionally use accelerator to compute dot product only
void apply_layer_dot(int n_in, int n_out, int *b, int *w, int use_relu, int *ifmap, int *ofmap)
{
    for (unsigned o = 0, wo = 0; o < n_out; ++o, wo += n_in) {
        fprintf(stdout, "bias %d: %lx\n", o, b[o]);
        int sum = b[o]; /* bias for the current output index */
      #if ( DONE_TASK7 )
        sum += dotprod_hw( n_in, &w[wo], ifmap );
      #else // BASELINE
        sum += dotprod_sw( n_in, &w[wo], ifmap );
        // fprintf(output_file, "Calculation %d: \n", o);
        // fprintf(output_file, "\t w: {");
        // for (int i = wo; i < n_in + wo; i++) {
        //     fprintf(output_file, "%08x, ", w[i]);
        // }
        // fprintf(output_file, "} \n");
        // fprintf(output_file, "\tifmap: {");
        // for (int i = 0; i < n_in; i++) {
        //     fprintf(output_file, "%08x, ", ifmap[i]);
        // }
        // fprintf(output_file, "} \n");

        fprintf(stdout, "\t Sum: %08x\n", sum);
      #endif
        if (use_relu) sum = (sum < 0) ? 0 : sum; /* ReLU activation */

        //fprintf(output_file, "\t Sum after ReLu: %08x\n", sum);
        ofmap[o] = sum;
    }
}

// ----------------------------------------------------------------

int max_index(int n_in, int *ifmap)
{
    int max_sofar = 0;
    for( int i = 1; i < n_in; ++i ) {
        if( ifmap[i] > ifmap[max_sofar] ) max_sofar = i;
    }
    return max_sofar;
}

int main(int argc, char ** argv)
{
    char *testfilepath;
    if (argc >= 2) {
        testfilepath = argv[1];
        if (argc >= 3) {
            output_file = fopen(argv[2], "w");
        } else {
            output_file = stdout;
        }
    } else {
        testfilepath = "../data/test_00.bin";
    }
    
    // Open nn.bin file and put everything into RAM
    FILE *nn_file = fopen("../data/nn.bin", "rb");
    if (nn_file == NULL) {
        fprintf(output_file, "Error openning file\n");
        return 1;
    }
    fseek(nn_file, 0, SEEK_END);
    long nn_filelen = ftell(nn_file);
    rewind(nn_file);

    nn = (int *) malloc(nn_filelen * sizeof(char));
    fread(nn, nn_filelen, 1, nn_file);


    // Open a test file and put everything into RAM
    FILE *test_file = fopen(testfilepath, "rb");
    if (test_file == NULL) {
        fprintf(output_file, "Error openning file\n");
        return 1;
    }
    fseek(test_file, 0, SEEK_END);
    long test_filelen = ftell(test_file);
    rewind(test_file);

    input = (int *) malloc(test_filelen * sizeof(char));
    fread(input, test_filelen, 1, test_file);

    // Allocate memory for activations
    l1_acts = malloc(sizeof(int) * L1_OUT);
    l2_acts = malloc(sizeof(int) * L2_OUT);
    l3_acts = malloc(sizeof(int) * L3_OUT);


    int *l1_b = nn;                    /* layer 1 bias */
    int *l1_w = l1_b + L1_OUT;         /* layer 1 weights */
    int *l2_b = l1_w + L1_IN * L1_OUT; /* layer 2 bias */
    int *l2_w = l2_b + L2_OUT;         /* layer 2 weights */
    int *l3_b = l2_w + L2_IN * L2_OUT; /* layer 3 bias */
    int *l3_w = l3_b + L3_OUT;         /* layer 3 weights */

    int result;
    apply_layer_dot( L1_IN, L1_OUT, l1_b, l1_w, 1,   input, l1_acts );
    fprintf(output_file, "L1 ACTIVATION numbers: \n");
    for (int i = 0; i < L1_OUT; i++) {
        fprintf(output_file, "\tIndex %d: %08x\n", i, l1_acts[i]);
    }
    
    //apply_layer_dot( L2_IN, L2_OUT, l2_b, l2_w, 1, l1_acts, l2_acts );
    // fprintf(output_file, "L2 ACTIVATION numbers: \n");
    // for (int i = 0; i < L2_OUT; i++) {
    //     fprintf(output_file, "\tIndex %d: %08x\n", i, l2_acts[i]);
    // }
    
    //apply_layer_dot( L3_IN, L3_OUT, l3_b, l3_w, 0, l2_acts, l3_acts );
    // fprintf(output_file, "L3 ACTIVATION numbers: \n");
    // for (int i = 0; i < L3_OUT; i++) {
    //     fprintf(output_file, "\tIndex %d: %08x\n", i, l3_acts[i]);
    // }
    
    result = max_index( L3_OUT, l3_acts );

    fprintf(output_file, "result: %d \n", result);
    
    fclose(nn_file);
    fclose(test_file);
    return 0;
}

