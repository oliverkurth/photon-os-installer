
```
docker build -t ova-creator .
mkdir -p ../repo ../workdir
docker run --privileged -ti --rm -v $(pwd)/../workdir:/workdir -v $(pwd)/../repo:/repo -v $(pwd)/../:/poi -v $(pwd):/ci -w /ci ova-creator
```

In the container, do:
```
./create-ova.sh
```
