# RPM

## Install common devel packages
```
sudo yum install gcc gcc-c++ rpm-build createrepo \
                 python-devel libxml2-devel libxslt-devel libffi-devel openssl-devel libvirt-devel liberasurecode-devel \
                 pulseaudio-libs-devel systemtap-sdt-devel bluez-libs-devel libusb1-devel vte3-devel librdmacm-devel \
                 iasl libuuid-devel SDL-devel libaio-devel usbredir-devel zlib zlib-devel ncurses-devel numactl-devel numactl-libs \
                 libgudev1 libcap-ng-devel jemalloc-devel libiscsi-devel libpcap-devel libcap-devel
```

## NginxでRPMを公開する
```
sudo apt-get -y install createrepo nginx

sudo mkdir -p /opt/nginx/yumrepo/centos/7/x86_64
sudo chown -R www-data:www-data /opt/nginx-repo
sudo mv *rpm /opt/nginx/yumrepo/centos/7/x86_64/
sudo createrepo /opt/nginx/yumrepo/centos/7/x86_64/

cat << EOS | sudo tee /etc/nginx/conf.d/yumrepo.conf
server {
    listen 8000;
    root /opt/nginx-repo;
    autoindex    on;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOS
```
