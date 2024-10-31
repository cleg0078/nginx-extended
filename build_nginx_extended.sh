#!/bin/bash

sudo apt install -y libmodsecurity-dev libmodsecurity3 cargo dpkg-dev zlib1g-dev

sudo apt install -y mercurial libmaxminddb-dev git gcc g++ gcc-12 g++-12 mold make cmake perl libunwind-dev golang ca-certificates ninja-build build-essential autoconf automake libtool gettext pkg-config libpcre3 libpcre3-dev libxml2 libxml2-dev libcurl4 libgeoip-dev libyajl-dev doxygen


rm -rf /tmp/nginx-extended

mkdir -p /tmp/nginx-extended
git clone https://github.com/google/ngx_brotli.git /tmp/nginx-extended/ngx_brotli
cd /tmp/nginx-extended/ngx_brotli && git submodule update --init && cd - 
git clone https://github.com/FRiCKLE/ngx_cache_purge.git /tmp/nginx-extended/ngx_cache_purge
git clone https://github.com/leev/ngx_http_geoip2_module.git /tmp/nginx-extended/ngx_http_geoip2_module
git clone https://github.com/nbs-system/naxsi.git /tmp/nginx-extended/naxsi
git clone https://github.com/openresty/headers-more-nginx-module.git /tmp/nginx-extended/ngx_headers_more
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /tmp/nginx-extended/ModSecurity
cd /tmp/nginx-extended/ModSecurity && git submodule init && git submodule update && cd -
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /tmp/nginx-extended/ModSecurity-nginx

git clone --branch 0.7.6 --depth=1 --recursive --shallow-submodules https://github.com/nginx/njs /tmp/nginx-extended/njs 
git clone --depth=1 --recursive --shallow-submodules https://github.com/AirisX/nginx_cookie_flag_module  /tmp/nginx-extended/nginx_cookie_flag_module


cd /tmp/nginx-extended

#git clone --depth 1 https://boringssl.googlesource.com/boringssl /tmp/nginx-extended/boringssl
#mkdir /tmp/nginx-extended/boringssl/build
#cd /tmp/nginx-extended/boringssl/build
export CC=/usr/bin/gcc-12
export CXX=/usr/bin/g++-12 

#cmake ..
#make -j 10


#mkdir -p "/tmp/nginx-extended/boringssl/.openssl/lib"
#cd "/tmp/nginx-extended/boringssl/.openssl"
#ln -s ../include include

## Copy the BoringSSL crypto libraries to .openssl/lib so nginx can find them
#cd "/tmp/nginx-extended/boringssl"
#cp "build/crypto/libcrypto.a" ".openssl/lib"
#cp "build/ssl/libssl.a" ".openssl/lib"

cd /tmp/nginx-extended/
hg clone https://hg.nginx.org/nginx  
cd /tmp/nginx-extended/nginx
#hg update quic

PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig/" auto/configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-compat --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-select_module --with-poll_module --with-stream_ssl_preread_module --add-module=/tmp/nginx-extended/ngx_brotli --add-module=/tmp/nginx-extended/ngx_cache_purge --add-module=/tmp/nginx-extended/ngx_http_geoip2_module --add-dynamic-module=/tmp/nginx-extended/ModSecurity-nginx --add-module=/tmp/nginx-extended/ngx_headers_more --with-compat --with-http_v3_module --add-module=/tmp/nginx-extended/njs/nginx --add-module=/tmp/nginx-extended/nginx_cookie_flag_module --add-module=/tmp/nginx-extended/naxsi/naxsi_src \
--with-cc-opt='-fuse-ld=mold -O3 -march=native -pipe -flto -ffat-lto-objects -fomit-frame-pointer -fstack-protector-all -fPIE -fPIC -fexceptions --param=ssp-buffer-size=4 -grecord-gcc-switches -pie -fno-semantic-interposition -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wformat-security -Wno-error=strict-aliasing -Wextra -Wp,-D_FORTIFY_SOURCE=2' \
 --with-ld-opt='-O3 -Wl,-Bsymbolic-functions -Wl,-z,relro' --with-cc=gcc-12 \

touch "/tmp/nginx-extended/boringssl/.openssl/include/openssl/ssl.h"

#PARALLEL MAKE
make -j 10 

#AUTOMATIC BUILD THE DEB PACKAGE 
#MAKE SURE YOU HAVE :
#0 -  Maintainer: [ postmaster@bitsabout.me ]
#1 -  Summary: [ bam-nginx ]
#2 -  Name:    [ nginx ]
#3 -  Version: [ 1.20.1 ]
#4 -  Release: [ 1 ]
#5 -  License: [ GPL ]
#6 -  Group:   [ checkinstall ]
#7 -  Architecture: [ amd64 ]
#8 -  Source location: [ nginx-1.20.1 ]
#9 -  Alternate source location: [  ]
#10 - Requires: [  ]
#11 - Recommends: [  ]
#12 - Suggests: [  ]
#13 - Provides: [ nginx ]
#14 - Conflicts: [  ]
#15 - Replaces: [  ]

sudo checkinstall make install 
