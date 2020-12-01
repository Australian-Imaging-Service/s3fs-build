# S3FS Container

A side container to mount S3 buckets as FUSE.

## Minio note

[Minio](https://min.io) is a high performance object store.

`use_path_request_style` option setting is required. There are some fundamental differences in the way Minio presents buckets via the URL than AWS S3 that requires some changes to the default s3fs settings. Namely the path to the s3 bucket is not part of the DNS prefix but a sub-path reference. I.e., AWS s3 https://BUCKET.s3.amazonaws.com == Minio https://s3.yourMinio.local/BUCKET.

## References

* [s3fs-fuse project](https://github.com/s3fs-fuse/s3fs-fuse)
* [FUSE README](https://github.com/fuse4x/fuse/blob/master/README)
