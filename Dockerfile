FROM alpine:3.16

ENV LANG="C.UTF-8" \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    TERM="xterm-256color"
    
COPY . /app/ring-mqtt
RUN apk add --no-cache tar xz git libcrypto1.1 libssl1.1 musl-utils musl bash curl jq tzdata nodejs npm mosquitto-clients && \
    APKARCH="$(apk --print-arch)" && \
    S6VERSION="v3.1.1.2" && \
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6VERSION}/s6-overlay-noarch.tar.xz" | tar -C / -Jxpf - && \
    case "${APKARCH}" in \
        aarch64|armhf|x86_64) \
            curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6VERSION}/s6-overlay-${APKARCH}.tar.xz" | tar -C / -Jxpf - ;; \
        armv7) \
            curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6VERSION}/s6-overlay-arm.tar.xz" | tar -C / -Jxpf - ;; \
        *) \
            echo >&2 "ERROR: Unsupported architecture '$APKARCH'" \
            exit 1 ;; \
    esac && \
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6VERSION}/s6-overlay-symlinks-noarch.tar.xz" | tar -C / -Jxpf - && \
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6VERSION}/s6-overlay-symlinks-arch.tar.xz" | tar -C / -Jxpf - && \
    mkdir -p /etc/fix-attrs.d && \
    mkdir -p /etc/services.d && \
    cp -a /app/ring-mqtt/init/s6/* /etc/. && \
    rm -Rf /app/ring-mqtt/init && \ 
    case "${APKARCH}" in \
        x86_64) \
            RSSARCH="amd64";; \
        aarch64) \
            RSSARCH="arm64v8";; \
        armv7|armhf) \
            RSSARCH="armv7";; \
        *) \
            echo >&2 "ERROR: Unsupported architecture '$APKARCH'" \
            exit 1;; \
    esac && \
    curl -L -s "https://github.com/aler9/rtsp-simple-server/releases/download/v0.18.2/rtsp-simple-server_v0.20.0_linux_${RSSARCH}.tar.gz" | tar zxf - -C /usr/local/bin rtsp-simple-server && \
    curl -J -L -o /tmp/bashio.tar.gz "https://github.com/hassio-addons/bashio/archive/v0.14.3.tar.gz" && \
    mkdir /tmp/bashio && \
    tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio && \
    mv /tmp/bashio/lib /usr/lib/bashio && \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio && \
    chmod +x /app/ring-mqtt/scripts/*.sh && \
    mkdir /data && \
    chmod 777 /data /app /run && \
    cd /app/ring-mqtt && \
    chmod +x ring-mqtt.js && \
    chmod +x init-ring-mqtt.js && \
    npm install && \
    rm -Rf /root/.npm && \
    rm -f -r /tmp/*
ENTRYPOINT [ "/init" ]

EXPOSE 8554/tcp
EXPOSE 55123/tcp

ARG BUILD_VERSION
ARG BUILD_DATE

LABEL \
    io.hass.name="Ring-MQTT with Video Streaming" \
    io.hass.description="Home Assistant Community Add-on for Ring Devices" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Tom Sightler <tsightler@gmail.com>" \
    org.opencontainers.image.title="Ring-MQTT with Video Streaming" \
    org.opencontainers.image.description="Intergrate wtih Ring devices using MQTT/RTSP" \
    org.opencontainers.image.authors="Tom Sightler <tsightler@gmail.com> (and various other contributors)" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/tsightler/ring-mqtt" \
    org.opencontainers.image.documentation="https://github.com/tsightler/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.version=${BUILD_VERSION}
