FROM node:8-alpine

ENV TZ=Asia/Tehran \
    # If you use Babel, Babel cache won't be useful with Docker as containers do not keep their state
    # (generating a cache on container start increases the start time).
    BABEL_DISABLE_CACHE=1

RUN apk update && \
    # Install required packages - you can find any additional packages here: https://pkgs.alpinelinux.org/packages
    apk add tzdata curl bash ca-certificates rsync supervisor nginx \
            python python-dev py-pip build-base libpng-dev autoconf automake nasm libtool && \
    # Set the timezone
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    # Set the nginx config
    sed -i "/user nginx;/c #user nginx;" /etc/nginx/nginx.conf && \
    # Create required directories
    mkdir -p /usr/src/app /.config /run/nginx /var/lib/nginx/logs && \
    chgrp -R 0        /var/log /var/run /var/tmp /run/nginx /var/lib/nginx && \
    chmod -R g=u,a+rx /var/log /var/run /var/tmp /run/nginx /var/lib/nginx && \
    # Log aggregation
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    # Clean up packages
    rm -rf /var/cache/apk/*

EXPOSE 8080
WORKDIR /usr/src/app

COPY supervisord.conf /
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Install app dependencies
COPY package.json /usr/src/app/

RUN npm install

# Bundle app source
COPY . /tmp/app

RUN chgrp -R 0 /tmp/app /.config && \
    chmod -R g=u /tmp/app /.config && \
    cp -a /tmp/app/. /usr/src/app && \
    rm -rf /tmp/app && \
    chmod +x start.sh

CMD ["./start.sh"]
USER 1001
