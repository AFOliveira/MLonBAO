export ROOT_DIR=$(realpath ..)
export ML_DIR=$ROOT_DIR/TrainedModels

scp $ML_DIR/mnistC/* root@192.168.42.15:/etc/mnistC
scp $ML_DIR/mnistDNN/* root@192.168.42.15:/etc/mnistDNN
scp $ML_DIR/cifar10/* root@192.168.42.15:/etc/cifar10