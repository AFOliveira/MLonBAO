cd /etc/mnistC

echo "Executong perf on MNISTCNN"

perf stat -e l2d_cache -e l2d_cache_refill -e bus_cycles -e bus_access python3 valTrain.py

cd /etc/mnistDNN

echo "Executong perf on MNISTDNN"

perf stat -e l2d_cache -e l2d_cache_refill -e bus_cycles -e bus_access python3 valTrain.py

cd /etc/cifar10

echo "Executong perf on CIFAR10"

perf stat -e l2d_cache -e l2d_cache_refill -e bus_cycles -e bus_access python3 valTrain.py

cd /etc
