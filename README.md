## Simple Dockerized AsterixDB

This projects aims to make it easy to get started with [AsterixDB](https://asterixdb.apache.org/). It is based on Docker and [Docker compose](https://docs.docker.com/compose/). Currently, the following features are supported:

* The [sample cluster](https://asterixdb.apache.org/docs/0.9.6/ncservice.html#quickstart) (which consists of one cluster controller and two node controllers) in a single container
* HDFS (with name node and data nodes in their own respective containers)

### Starting AsterixDB without HDFS

If you do not need HDFS, you can use the docker image without `docker-compose`:

```bash
docker run --rm -it -p 19002:19002 -p 19006:19006 ingomuellernet/asterixdb
```

### Starting AsterixDB with HDFS

The following should be enough to bring up all required services:

```bash
docker-compose up
```

### Varying the number of HDFS Data Nodes

To change the number of HDFS data nodes, use the `--scale` flag of docker-compose:

```bash
docker-compose up --scale datanode=3
```

### Building the Image Locally

Above command uses a pre-built [docker image](https://hub.docker.com/r/ingomuellernet/asterixdb). If you want the image to be build locally, do the following instead:

```bash
docker-compose --file docker-compose-local.yml up
```

If you are behind a corporate firewall, you will have to configure Maven (which is used to build part of AsterixDB) as follows before running above command:

```bash
export MAVEN_OPTS="-Dhttp.proxyHost=your.proxy.com -Dhttp.proxyPort=3128 -Dhttps.proxyHost=your.proxy.com -Dhttps.proxyPort=3128"
```

### Uploading Data to HDFS

The `data/` folder is mounted into the HDFS namenode container, from where you can upload it using the HDFS client in that container (`docker-asterixdb_namenode_1` may have a different name on your machine; run `docker ps` to find out):

```bash
docker exec -it docker-asterixdb_namenode_1 hadoop fs -mkdir /dataset
docker exec -it docker-asterixdb_namenode_1 hadoop fs -put /data/file.parquet /dataset/
docker exec -it docker-asterixdb_namenode_1 hadoop fs -ls /dataset
```

### Running Queries

Once started, you should be able to use the server by accssing http://localhost:19006. Alternatively, the [REST API](https://ci.apache.org/projects/asterixdb/api.html) is accessible on the standard port.

### Creating an External Table

Suppose you have the following file `test.json`:

```json
{"s": "hello world", "i": 42}
```

Upload it to `/dataset/test.json` on HDFS as described above. Then run the following in the web interface:

```SQL
CREATE TYPE t1 AS OPEN {};

CREATE EXTERNAL DATASET Test(t1)
USING hdfs (
  ("hdfs"="hdfs://namenode:8020"),
  ("path"="/dataset/test.json"),
  ("input-format"="text-input-format"),
  ("format"="json")
);

```
