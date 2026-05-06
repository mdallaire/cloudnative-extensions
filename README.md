# cloudnative-extensions

Container images for [cloudnative-pg](https://cloudnative-pg.io/) with the following extensions installed:

- [VectorChord](https://github.com/tensorchord/VectorChord) — high-performance vector search
- [TimescaleDB](https://www.timescale.com/) — time-series data management

> [!IMPORTANT]
> If you are using this image on an existing database, the postgres configuration needs to be
> altered to enable the extensions. You can do this by setting `shared_preload_libraries` in your Cluster spec:
> ```yaml
> apiVersion: postgresql.cnpg.io/v1
> kind: Cluster
> spec:
>   (...)
>   postgresql:
>     shared_preload_libraries:
>       - "vchord.so"
>       - "timescaledb"
>   ```

> [!IMPORTANT]
> Extensions are not enabled by default. You need to enable them when initializing the database. You can configure this in your Cluster spec:
> ```yaml
> apiVersion: postgresql.cnpg.io/v1
> kind: Cluster
> spec:
>   (...)
>   bootstrap:
>     initdb:
>       postInitSQL:
>         - CREATE EXTENSION IF NOT EXISTS vchord CASCADE;
>         - CREATE EXTENSION IF NOT EXISTS timescaledb;

## Building

To build the Dockerfile locally, you need to pass the `CNPG_TAG`, `VECTORCHORD_TAG`, and `TIMESCALE_TAG` args. For example:  
`docker build . --build-arg="CNPG_TAG=17.9" --build-arg="VECTORCHORD_TAG=1.1.1" --build-arg="TIMESCALE_TAG=2.26.4"`
