
mkdir ca
cd ca
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -days 3650 -req -signkey server.key -in server.csr -out server.crt

openssl x509 -days 3650 -req -signkey certs/domain.key -in certs/domain.csr -out certs/domain.crt


mkdir certs
openssl req -newkey rsa:2048 -nodes -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
sudo mkdir -p /etc/docker/certs.d/ip-172-31-7-161:5000/
sudo cp certs/domain.crt /etc/docker/certs.d/ip-172-31-7-161:5000/ca.crt



docker run -d -p 5000:5000 --rm --name registry \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -v $(pwd)/regist:/var/lib/registry \
  registry:2

docker run -d -p 443:443 --rm --name registry \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -v $(pwd)/regist:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  registry:2

docker run -d -p 443:443 -p 80:80 --rm --name nginx nginx

docker run -d -p 443:443 -p 80:80 --rm --name nginx -v $(pwd)/certs:/etc/nginx/ssl/certs nginx

docker run -d -p 443:443 -p 80:80 --rm --name nginx \
 -v $(pwd)/nginx_certs/:/etc/nginx/ssl/ \
 -v $(pwd)/nginx/conf.d/:/etc/nginx/conf.d/ \
 -v $(pwd)/nginx/docker-registry.conf:/etc/nginx/docker-registry.conf \
 nginx

docker run  -d -p 443:443 -p 80:80 --rm --name nginx  -v $(pwd)/nginx_certs/:/etc/nginx/ssl/  -v $(pwd)/nginx/server.conf:/etc/nginx/conf.d/server.conf  nginx


openssl req -newkey rsa:2048 -nodes -keyout certs2/domain.key -x509 -days 365 -out certs2/domain.crt
 docker run -d -p 443:443 \
   --rm --name registry \
   -v `pwd`/certs:/certs \
   -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
   -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
   -v $(pwd)/regist:/var/lib/registry \
   -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
   registry:2
memo 
sudo vi /etc/ssl/openssl.cnf
[ v3_ca ]
subjectAltName=IP:192.168.31.1