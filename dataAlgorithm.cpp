#define N 250000

struct Tick {
    int sma13;
    int ema50;
    int ema100;
    int ema200;
    double rsi;
    double stochK;
    double stochD;
    double prcUpper;
    double prcLower;
};

int tickCount = 1000000;
int configurationCount = N;
int i = 0;
int j = 0;

// Create a two-dimensional array of ticks of dimensions (tickCount x configurationCount).
struct **data = (Tick**)malloc(tickCount * sizeof(Tick*));
for (i=0; i<configurationCount; i++) {
    data[i] = (Tick*)malloc(configurationCount * sizeof(test));
}

// Loop through all data.
for (i=0; i<tickCount; i++) {
    // Loop through all configurations.
    for (j=0; j<configurationCount; j++) {
        // Retrieve the target field name for the current configuration.
        // ...

        // Retrieve the target field value for the current configuration.
        // ...

        // Create a new tick
        // ...

        // Set the properties of the tick using the retrieved target field values.
        // ...

        // Add the tick to the list for the current tick index.
        // ...
    }
}