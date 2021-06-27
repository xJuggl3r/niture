variable "ad_region_mapping" {
  type = map(string)

  default = {
    us-phoenix-1 = 3
    us-ashburn-1 = 2
    sa-saopaulo-1 = 1
  }
}

variable "images" {
  type = map(string)

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Oracle-Linux-7.9-2020.10.26-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaacirjuulpw2vbdiogz3jtcw3cdd3u5iuangemxq5f5ajfox3aplxa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaabbg2rypwy5pwnzinrutzjbrs3r35vqzwhfjui7yibmydzl7qgn6a"
    sa-saopaulo-1   = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaudio63gdicxwujhfok7jdyewf6iwl6sgcaqlyk4fvttg3bw6gbpq"
  }
}

# Script para instalacao do Apache, download e deploy da Aplicao Niture
variable "deploy-niture" {
  default = <<EOF
#!/bin/bash -x
echo '################### Webserver Niture #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## Atualizacoes ###############'
# yum update -y
echo '########## Basic Webserver ##############'
yum install -y httpd
systemctl enable  httpd.service
systemctl start  httpd.service

# echo '########## Download da Aplicacao Niture ###############'
cd /var/www/html/
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/u8j40_AS-7pRypC5boQT24w5QFPDTy-0j27BWBOfmsxbERTiuDtJQBIqfcsOH81F/n/idqfa2z2mift/b/bootcamp-oci/o/oci-f-handson-modulo-compute-website-files.zip
unzip oci-f-handson-modulo-compute-website-files.zip
chown -R apache:apache /var/www/html
rm -rf oci-f-handson-modulo-compute-website-files.zip

# echo '########## Regras do Firewall ###############'
firewall-offline-cmd --add-service=http
systemctl enable  firewalld
systemctl restart  firewalld
touch ~opc/userdata.`date +%s`.finish
echo '################### Webserver Niture Final #######################'
EOF

}