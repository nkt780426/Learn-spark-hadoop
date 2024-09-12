# Tạo network bigdata
docker network create bigdata --driver bridge

docker build -t jupyter-sparksubmit .
# Xem thống số
1. Spark Standarlone tại [đây](https://spark.apache.org/docs/latest/spark-standalone.html)
1. bitnami/spark 3.5.0 inage tại [đây](https://hub.docker.com/layers/bitnami/spark/3.5.0/images/sha256-896d500be4539279d23eac02e92a7a77464b5a1c6a30de4a99970a068c13335d?context=explore)

# Xem cấu hình spark vs nessie vs minio tại
https://blog.min.io/manage-iceberg-tables-with-spark/
https://projectnessie.org/iceberg/spark/#writing
https://iceberg.apache.org/releases/#150-release
https://iceberg.apache.org/docs/1.5.1/aws/#enabling-aws-integration 
https://projectnessie.org/guides/spark-s3/#setting-up-spark-session-for-minio

# Bug xung đột phiên bản
https://github.com/kubeflow/spark-operator/issues/1508
hadoop vs s3a:

# Hadoop vs s3a
Nguồn: https://hadoop.apache.org/docs/stable/hadoop-aws/tools/hadoop-aws/index.html#Introducing_the_Hadoop_S3A_client
Tóm tắt:
1. Ngày viết: 2023-6-18 version 3.3.6
2. Các dependence cần thiết
    hadoop-common: thêm các dependence của nó (nó chỉ bao gồm aws-sdk), tất cả phải cùng 1 version
        hadoop-aws:
        hadoop-client: 
3. warnings:
    Thư mục giả lập (Mimicked Directory)
        Các hệ thống lưu trữ hướng đối tượng như minio, s3 chỉ lưu trữ các bucket chứ không lưu trữ thư mục
        Tạo thư mục giả lập bằng mkdir => Khi lưu trữ 1 file vào đây thi thư mục này tự xóa => Không create path bằng spark hay flink, ... được. Điều này đảm bảo an toàn 
        ... (không hiểu)
    Các phương thức authorization khác nhau
        s3a client chỉ việc submit các thông tin
            File owner và File group đều là current user theo mặc định, trước hadoop 2.8 thì đây là empty
            Quyền thư mục là 777 và file là 666
        User authenticate bằng AWS credentials
    Khai báo AWS credentials
        Cẩn thận lộ key thì toang: không ném lên SCM (git, ...), không log ra console hay chia sẻ file .env
        Clients được support nhiều loại xác thực:
            Tiên quyết implement thuộc tính: 
                fs.s3a.access.key=MINIO_ACCESS_KEY
                fs.s3a.secret.key=MINIO_SECRET_KEY
                fs.s3a.aws.credentials.provider: Dùng để khai báo nhà cung ứng (provider) nhận thông tin xác thực
                    2 trường phái: AWS Credential Providers và Hadoop Credential
                        AWS Credential (có trong amazon sdk)
                            com.amazonaws.auth.AWSCredentialsProvider với aws java sdk v1 
                            software.amazon.awssdk.auth.credentials.AwsCredentialsProvider với aws java sdk v2 (project này dùng budel 2.17.178)
                            Còn rất nhiều cái khác nữa
                        Hadoop Credential (có trong hadoop-aws):
                            org.apache.hadoop.fs.s3a.AnonymousAWSCredentialsProvider: chỉ định cái này sẽ cho phép truy cập public S3 bucket mà không cần thông tin xác thực (chủ yếu dùng trong kiểm thử)
                            org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider: sử dụng 2 biến key trên để xác thực (nên dùng cái này trong hầu hết trường hợp)
                            org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider: session credentials (đọc phần token ở dưới)
                            org.apache.hadoop.fs.s3a.auth.AssumedRoleCredentialProvider: không biết nhưng chắc không dùng

                fs.s3a.session.token: Có thể tạo token giới hạn thời gian sử dụng (hoặc không) nếu dùng thì
                    fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider
                    com.amazonaws.auth.EnvironmentVariableCredentialsProvider: sử dụng biến môi trường AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY để xác thực
                    com.amazonaws.auth.InstanceProfileCredentialsProvider: Chỉ dùng nếu đang có EC2
            Các biến 

# Chỉnh sửa quyền trong accesskey
Lỗi: Py4JJavaError: An error occurred while calling o62.parquet.
: java.nio.file.AccessDeniedException: s3a://spark/customer.parquet: getFileStatus on s3a://spark/customer.parquet: com.amazonaws.services.s3.model.AmazonS3Exception: Forbidden (Service: Amazon S3; Status Code: 403; Error Code: 403 Forbidden; Request ID: VBNCN3TVEAQR8ZMC; S3 Extended Request ID: lIn7bp9nPkBksTHE8FePXQEq6s/NmaPzXbuY2snyurFFmpyQh9ZJNFIljkqV/NdzS4cKtBUSY5s=; Proxy: null), S3 Extended Request ID: lIn7bp9nPkBksTHE8FePXQEq6s/NmaPzXbuY2snyurFFmpyQh9ZJNFIljkqV/NdzS4cKtBUSY5s=:403 Forbidden
https://medium.com/@pflooky/aws-s3-access-denied-b2cc54079bb0
https://min.io/docs/minio/container/administration/identity-access-management/policy-based-access-control.html

![minio policy.png](../images/minio%20policy.png)