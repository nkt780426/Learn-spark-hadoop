# Nguồn
Xem mẫu youtube đê biết cơ bản (không làm theo): https://www.youtube.com/watch?v=Slbi-uzPtnw
Làm theo document của hãng: https://hadoop.apache.org/docs/r3.4.0/hadoop-project-dist/hadoop-common/ClusterSetup.html
# B1: Dựng 5 máy ảo: 
1. Dùng virtual box tạo 1 máy ảo ubuntu và thêm 1 host-only adapter network, thêm ssh key để local có thể ssh không mật khẩu đến máy này. Thực hiện tắt cloud-init trên máy (đọc tạo máy ảo ubuntu), update.
2. Tải hadoop về máy local và đưa về máy ảo bởi lệnh scp.
```sh
scp <local path> vohoang@<ip-máy ảo>:/home/vohoang/hadoop-3.4.0.tar.gz
sudo tar -zxvf hadoop-3.4.0.tar.gz
```
3. Cài open-jdk 8.
```sh
sudo apt install openjdk-8-jdk -y

# Thêm vào .bashrc
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

export HADOOP_HOME=$HOME/hadoop-3.4.0
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
```
3. Thêm dns vào các machine
```sh
sudo vi /etc/hosts

# Hadoop cluster
192.168.56.131 namenode
192.168.56.132 resourcemanager
192.168.56.133 datanode1
192.168.56.134 datanode2
192.168.56.135 datanode3
```
4. Clone thêm 4 máy ảo. 
5. Cấu hình netplan cho 5 máy ảo (cấu hình lại địa chỉ host-only interface và nameserver) và đổi hostname cho mỗi máy.
    NameNode: 192.168.56.131.
    ResourceManager: 192.168.56.132.
    DataNode1: 192.168.56.133.
    DataNode2: 192.168.56.134.
    DataNode3: 192.168.56.135.
# B2: Config các file
Xem các tham số mặc định tại đây.

[default-config](/images/1.hadoop_config_file.png)

Nếu muốn tùy chỉnh gì khác thì ghi đè vào các file trong thư mục etc/hadoop
Các tham số phổ biến thường dùng xem tại [đây](https://hadoop.apache.org/docs/r3.4.0/hadoop-project-dist/hadoop-common/ClusterSetup.html).
1. namenode
```sh
sudo vi etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode:9000</value>
    </property>
</configuration>

sudo vi etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>${user.home}/hadoop-3.4.0/data/namenode</value>
    </property>
</configuration>

sudo vi etc/hadoop/mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>

sudo vi etc/hadoop/workers
datanode1
datanode2
datanode3
```
2. Resource Manager
```sh
sudo vi etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode:9000</value>
    </property>
</configuration>

sudo vi etc/hadoop/yarn-site.xml
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>resourcemanager</value>
    </property>
</configuration>

sudo vi etc/hadoop/mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>

sudo vi etc/hadoop/workers
datanode1
datanode2
datanode3
```
3. Datanode + Namenode
```sh
sudo vi etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode:9000</value>
    </property>
</configuration>

sudo vi etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>${user.home}/hadoop-3.4.0/data/datanode</value>
    </property>
</configuration>

sudo vi etc/hadoop/yarn-site.xml
<configuration>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>4096</value>
    </property>
    <property>
        <name>yarn.nodemanager.log.retain-seconds</name>
        <value>10800</value>
    </property>
    <property>
        <name>yarn.nodemanager.remote-app-log-dir</name>
        <value>/logs</value>
    </property>
    <property>
        <name>yarn.nodemanager.remote-app-log-dir-suffix</name>
        <value>logs</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>

sudo vi etc/hadoop/mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```
# B3: Thêm ssh key vào các datanode/nodemanager
Để có thể đơn giản hóa quá trình triển khai (không phải start từng daemon 1 trên tất cả các máy), cần thêm ssh-key của namenode và resource manager vào worker node
```sh
# Tạo ssh-key trên namenode và resource manager node
ssh-keygen -t ed25519 -C "hadoop"

# Thêm chính key đó vào chính node đó và các datanode
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys && \
chmod 0600 ~/.ssh/authorized_keys

ssh-copy-id -i ~/.ssh/id_ed25519.pub vohoang@192.168.56.133
ssh-copy-id -i ~/.ssh/id_ed25519.pub vohoang@192.168.56.134
ssh-copy-id -i ~/.ssh/id_ed25519.pub vohoang@192.168.56.135
```
Ngoài ra cần phải thêm ip/dns của các datanode mà namenode/resource manager có thể truy cập đến vào file etc/hadoop/workers (đã làm ở bước 2)
# B4: Dựng hadoop
Data/logs được lưu tại thư mục: ~/hadoop-3.4.0/data
1. Lần đâu tiên dựng HDFS cần phải format tất cả các file trên tất cả các node.
```sh
sudo chown -R vohoang:vohoang /home/vohoang/hadoop-3.4.0
hdfs namenode -format
```
2. Tại namenode dựng các tiến trình daemon hdfs
```sh
start-dfs.sh
# Kiểm tra bằng lệnh
jps
```
3. Tại resource manager dựng các tiến trình daemon yarn
```sh
start-yarn.sh
# Kiểm tra bằng lệnh
jps
```
4. Cấp quyền đọc/ghi tại thư mục root (không bảo mật)
```sh
hdfs dfs -chmod 777 /
```
5. Trong quá trình triển khai chẳng may xảy ra lỗi thì sao ?
```sh
# Stop tất cả các tiến trình daemon
stop-dfs.sh
stop-yarn.sh
# Xóa tất cả thư mục logs và data tại /home/hadoop/hadoop-3.4.0/logs và /home/hadoop/hadoop-3.4.0/data trên các node
# Làm lại 3 bước trên
```
# B5: Thêm hadoop dns cho máy windown và wsl
Khi dùng web ui để upload file lên hdfs thì cần máy đó phải biết dns của cụm hdfs.
Kiến trúc mạng trng config này.
- Máy local có địa chỉ 192.168.56.1/24 và 5 máy ảo trên thuộc cùng 1 network.
- Máy local là windown-172.22.32.1/20(ipconfig) chạy wsl-172.22.44.112/20(ip a)
Để đề phòng set dns trên cả wsl và windown
1. WSL: thêm vào file /etc/hosts (mỗi lần tắt máy thông tin trong file này sẽ được reset lại từ đầu)
2. Windown: mở notepad vs quyền administrator. File -> Open và mở file 'C:\Windows\System32\drivers\etc\hosts
' (Chọn All Files" ở phần "File type" để thấy được file hosts).
```sh
Ping bằng dns trên windown và wsl để kiểm tra
# Hadoop cluster
192.168.56.131 namenode
192.168.56.132 resourcemanager
192.168.56.133 datanode1
192.168.56.134 datanode2
192.168.56.135 datanode3
```
Đặc biệt nếu chạy 1 container khác cũng phải thêm cấu hình trên vào /etc/hosts của container đó. 
Ví dụ như thêm vào spark cluster từng file /etc/hosts (bằng volume)
# B6: Truy cập giao diện hadoop
Xem cuối [document](https://hadoop.apache.org/docs/r3.4.0/hadoop-project-dist/hadoop-common/ClusterSetup.html) các port của namenode và resource manager

[web interface](../../../images/1.hadoop_web_interface.png)

Truy cập namenode ui

[namenode ui](../../../images/1.hadoop_datanode.png)

[file system](../../../images/1.hadoop_fs_ui.png)

Truy cập resource manager ui

[resource manager ui](../../../images/1.hadoop_rm_ui.png)