# Minio

[toc]

## 安装

使用brew install minio无法登陆，故使用docker安装

```dockerfile
docker run \
        -p 9000:9000 \
        -p 9001:9001 \
        --name minio1 \
        -v  ~/workspace/minio:/data \
        -e "MINIO_ROOT_USER=AKIAIOSFODNN7EXAMPLE" \
        -e "MINIO_ROOT_PASSWORD=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
        quay.io/minio/minio server /data --console-address ":9001"
```