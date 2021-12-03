ARG version=latest
FROM openjdk:$version

# version <= 11
RUN apt-get update \
    && apt-get install -y make maven || true
COPY prism/prism/nginx/cert.crt /usr/local/share/ca-certificates/cert.crt
RUN update-ca-certificates || true

# version > 11
RUN yum update -y \
    && yum install -y make wget || true
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo \
    && yum install -y maven || true
RUN keytool -importcert -trustcacerts -keystore cacerts -ext san=dns:api.sendgrid.com,dns:*.sendgrid.com,dns:sendgrid.com -storepass changeit -noprompt \
    -alias api.sendgrid.com -file /usr/local/share/ca-certificates/cert.crt || true
RUN keytool -list -v -keystore cacerts

WORKDIR /app
COPY . .

RUN make install
