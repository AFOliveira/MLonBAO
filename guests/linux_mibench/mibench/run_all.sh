#! /bin/sh

MIBENCH_DIR=$(pwd)

WARM_UP=10
REPETITIONS=30

cd $MIBENCH_DIR/automotive/qsort
echo "-> mibench/automotive/qsort-small"
seq $WARM_UP | xargs -Iz ./runme_small.sh
perf stat --table -r $REPETITIONS ./runme_small.sh
echo "-> mibench/automotive/qsort-large"
seq $WARM_UP | xargs -Iz ./runme_large.sh
perf stat --table -r $REPETITIONS ./runme_large.sh

cd $MIBENCH_DIR/automotive/susan
echo "-> mibench/automotive/susanc-small"
seq $WARM_UP | xargs -Iz ./runme_small-c.sh
perf stat --table -r $REPETITIONS ./runme_small-c.sh
echo "-> mibench/automotive/susanc-large"
seq $WARM_UP | xargs -Iz ./runme_large-c.sh
perf stat --table -r $REPETITIONS ./runme_large-c.sh
echo "-> mibench/automotive/susane-small"
seq $WARM_UP | xargs -Iz ./runme_small-e.sh
perf stat --table -r $REPETITIONS ./runme_small-e.sh
echo "-> mibench/automotive/susane-large"
seq $WARM_UP | xargs -Iz ./runme_large-e.sh
perf stat --table -r $REPETITIONS ./runme_large-e.sh
echo "-> mibench/automotive/susans-small"
seq $WARM_UP | xargs -Iz ./runme_small-s.sh
perf stat --table -r $REPETITIONS ./runme_small-s.sh
echo "-> mibench/automotive/susans-large"
seq $WARM_UP | xargs -Iz ./runme_large-s.sh
perf stat --table -r $REPETITIONS ./runme_large-s.sh

cd $MIBENCH_DIR/automotive/bitcount
echo "-> mibench/automotive/bitcount-small"
seq $WARM_UP | xargs -Iz ./runme_small.sh
perf stat --table -r $REPETITIONS ./runme_small.sh
echo "-> mibench/automotive/bitcount-large"
seq $WARM_UP | xargs -Iz ./runme_large.sh
perf stat --table -r $REPETITIONS ./runme_large.sh

cd $MIBENCH_DIR/automotive/basicmath
echo "-> mibench/automotive/basicmath-small"
seq $WARM_UP | xargs -Iz ./runme_small.sh
perf stat --table -r $REPETITIONS ./runme_small.sh
echo "-> mibench/automotive/basicmath-large"
seq $WARM_UP | xargs -Iz ./runme_large.sh
perf stat --table -r $REPETITIONS ./runme_large.sh
