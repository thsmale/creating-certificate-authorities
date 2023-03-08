# Create your own CA

## TLDR;
```sh
openssl req -nodes -new -x509 -days 1 \
  -keyout ca-key.pem \
  -subj "/C/US/ST=California/L=Palo Alto/O=Tommy/OU=IF/CN=ca" \
  -out ca.crt
  
openssl genrsa -out server.key

openssl req -new -key server.key \
  -subj = "/C=US/ST=California/L=Palo Alto/O=Tommy/OU=IF/CN=localhost"\
  -out server-csr.pem
 
openssl x509 -req -days 1 -in server-csr.pem \
  -CA test/ssl/ca.crt -CAkey ca-key.pem \
  -CAcreateserial -out server.crt

openssl verify -CAfile ca.crt server.crt
```

This is script to create your own certificate authority and chain. This has been used to generate test certificates for a nodejs server. It was used to test @hapi/Wreck HTTPS requests against a fake TLS server.

This can also be included in a Jenkinsfile to create certificates dynamically. Shoutout Haley Tortorich of HPE for supplying the -batch and -subj options to disable any prompts.

Most of this code is a compliation of the guide [openssl-certificate-authority](https://jamielinux.com/docs/openssl-certificate-authority/)

## Running locally. 

This assumes you have a unix based system and openssl installed. 

```sh
git clone https://github.com/thsmale/creating-certificate-authorities.git
cd creating-your-own-ca
touch root/index.txt intermediate/index.txt
mkdir root/newcerts intermediate/newcerts
chmod u+x script.sh
./script.sh
```

After the certificates are created the script will veryify the certificate chain. If it was successfull the output will be this
```
intermediate/cert.pem OK
server/cert.pem OK
```

## Example usage
This is a [10 second video](https://www.youtube.com/watch?v=Sr6QjxpVgkc) where I created a certificate chain that a localhost:8443 server could use for TLS. Note in this version of the script the -batch options and -subj options are not included in the script. Remove those options if you would like to manually sign and enter the CSR information.


## Notes
These certificates are hard coded to expire after 14600 days which is like 24 years. That may make sense for a root certificate but for the intermediate or server certificate 365 days is typical. 

The default bit encryption is 2048. You may want to use 4096 bit encryption for the root and intermediate certificate. 
