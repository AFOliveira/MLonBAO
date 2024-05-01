# 1. Build Docker Image

Inside `docker` directory run:

```sh
docker build -t ml_on_bao .
```

# 2. Run Docker

Inside the folder desired folder, run:
``` sh
docker run --rm -it -u root -v "$(pwd):$(pwd)" -w "$(pwd)" ml_on_bao
```

For instance, to build a linux image (on root directory):

```sh
git clone https://github.com/Diogo21Costa/evaluation-guests.git
cd evaluation-guests
git checkout feat/reconfigure_buildroot
cd benchmarks/linux_mibench 

docker run --rm -it -u root -v "$(pwd):$(pwd)" -w "$(pwd)" ml_on_bao
bash build_linux.sh
```

