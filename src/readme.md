# Kinh nhiệm install hadoop
Download tại [đây](https://hadoop.apache.org/releases.html), click vào version mới nhất và nhấn vào release notes để đọc doc cài đặt với version đó
Có 2 cách cài đặt
1. Cài đặt standarlone vào linux (thường ưu tiên cách này hơn vì dùng hadoop tức dữ liệu phải lớn)

[standarlone](./images/1.hadoop_setup.png)

[cách cấu hình config file](./images/1.hadoop_config_file.png)

2. Cài đặt [container](https://hub.docker.com/r/apache/hadoop)
Khi dựng hadoop cluster cần lưu ý:
1. Cần tách riêng namenode và resource manager node trong môi trường production
2. Không nên dùng hadoop để chứa các file dung lượng nhỏ vì có thể gây quá tải nammenode như lưu trữ 1 dataset các ảnh.
    Vì hdfs lưu trữ dữ liệu theo kiểu block và mỗi block mặc định chứa 256 MB. Nếu 1 block chứa quá nhiều file thì sẽ gây khó khắn cho namenode quản lý metadata của các file này. 
    **HDFS chỉ nên được sử dụng khi phải xử lý các file có dung lượng rất lớn (phải vài block mới đủ) như vậy mới tối ưu về mặt hiệu suất về lưu trữ cũng như xử lý**. 
    Nếu gặp phải trường hợp lưu trữ dữ liệu nhỏ thì nên dùng object storage như minio/s3 để lưu trữ.
3. Hadoop core thuộc hadoop ecosystem nên dễ dàng tích hợp với các project thuộc hadoop ví dụ như apache spark (do đó khi dùng spark tương tác với hadoop thường ko cần cấu hình nhiều). Còn với các sản phẩm ngoài hadoop ecosystem thì đọc doc của họ.
4. Hadoop chỉ hoạt động với java 8 hoặc 11. Đọc tại [đây](https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions) dể biết version phù hợp. Tốt nhất cài java 8.
# Kinh nhiệm install spark
Download tại [đây](https://spark.apache.org/downloads.html)
Có 2 cách cài đặt
1. Cài standarlone trên linux
2. Cài container. Hiện nay 1 xu hướng cài cluster trên k8s được ưa chuộng vì khi không cần xử lý chỉ cần shutdown container đi để giải phóng tài nguyên. Dùng [helm](https://artifacthub.io/packages/helm/bitnami/spark) để cài cho nhanh 
Lưu ý
1. Cẩn thận khi cài version mới nhất.
    Spark là nền tảng xử lý batch phổ biến nhất. Do đó được rât nhiều các công nghệ khác được tích hợp vào như apache iceberg, ... Khi bạn muốn tích hợp các công nghệ này vào spark có thể các công nghệ này chưa hỗ trợ tích hợp với spark phiên bản mới nhất.
2. Muốn cài spark phải cài 1 cluster manager trước.
    Bản thân spark standarlone cũng có 1 cluster manager của riêng mình. Bạn có thể sử dung nó mà không cần tích hợp với các hệ sinh thái lớn hơn như kubernetes, yarn. Tuy nhiên khi cài spark cluster vào hệ sinh thái phân tán trên, cần tích hợp với cluster manager của hệ sinh thái đó.
3. Không dùng spark 1 node trong môi trường production. Vì dùng spark phải dùng phân tán.
4. Spark hỗ trợ các dịch vụ aws như s3 nhưng minio không phải aws service nên phải cài đặt khác. Minio sử dụng giao thức s3a không phải s3. Đọc tài liệu [hadoop s3a](https://hadoop.apache.org/docs/current/hadoop-aws/tools/hadoop-aws/index.html) với version chính xác hadoop core để biết cách cấu hình chính xác.