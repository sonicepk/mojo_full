FROM alpine:3.11

RUN mkdir /opt/mojo_full
#copy everything from current dir to the 
COPY . /opt/mojo_full/

WORKDIR /opt/mojo_full/

RUN apk update && \
  apk add perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl sipcalc ipcalc && \
  curl -L https://cpanmin.us | perl - App::cpanminus && \
  cpanm --installdeps . -M https://cpan.metacpan.org && \
  apk del perl-dev g++ make wget curl && \
  rm -rf /root/.cpanm/* /usr/local/share/man/*

#USER daemon
EXPOSE 80

CMD ["hypnotoad", "-f", "script/my_ip"]

