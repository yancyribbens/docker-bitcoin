# docker-bitcoin

# build
```
docker build . -t bitcoind --build-arg NETWORK=testnet --build-arg RPC_USER=usr --build-arg RPC_PASSWORD=pwd
```

# run
```
docker run -it bitcoind bash
```
