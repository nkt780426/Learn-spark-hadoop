# Nguồn:
Đọc file từ hdfs: https://www.youtube.com/watch?v=oiyF5EFflf8
Xem các tham số cấu hình 
- bitnami/spark image tại [đây](https://hub.docker.com/r/bitnami/spark).
- jupyter/pyspark-notebook tại [đây](https://hub.docker.com/r/jupyter/pyspark-notebook): Lưu ý image này đã ko còn được update trên docker mà chuyển qua quay.io (đọc doc để biết thêm). Tuy nhiên bài này vẫn sử dụng version cuối cùng trên docker vì nó là 3.5.0.
# B1: Tạo pyspark-notebook image để thêm các thư viện cần thiết
```sh
docker build -t jupyter-sparksubmit .
```
# B2: Dựng spark cluster
```sh
docker network create bigdata --driver bridge
docker compose up -d
```
# B3: Truy cập các ui
Vào log jupyter để truy cập jupyter
Vào localhost:8090 để truy cập spark driver ui và local:8091-8093 để truy cập worker ui