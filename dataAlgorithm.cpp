#define N 250000

struct Tick {
    long timestamp;
    double open;
    double high;
    double low;
    double close;
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
Tick **ticks = (Tick**) malloc(tickCount * sizeof(Tick*));
for (i=0; i<tickCount; i++) {
    ticks[i] = (Tick*) malloc(configurationCount * sizeof(Tick));
}

// Loop through all ticks.
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