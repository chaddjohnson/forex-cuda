#define N 250000

struct Tick {
    double sma13;
    double ema50;
    double ema100;
    double ema200;
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
// Source: http://stackoverflow.com/a/3275389/83897
Tick **data = (Tick**)malloc(tickCount * sizeof(Tick*));
for (i=0; i<tickCount; i++) {
    data[i] = (Tick*)malloc(configurationCount * sizeof(Tick));
}

// Loop through all data.
for (i=0; i<tickCount; i++) {
    // Loop through all configurations.
    for (j=0; j<configurationCount; j++) {
        // Retrieve the target field name for the current configuration.
        // ...

        // Retrieve the target field value for the current configuration.
        // ...

        // Create a new tick.
        // ...

        // Set the properties of the tick using the retrieved target field values.
        // ...

        // Add the tick to the list for the current tick index.
        // ...
    }
}