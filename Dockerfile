ARG HSVERSION=0.22.1

FROM alpine:latest as build
ARG HSVERSION
WORKDIR /app

RUN wget https://github.com/juanfont/headscale/releases/download/v${HSVERSION}/headscale_${HSVERSION}_linux_amd64 \
    && mv headscale_${HSVERSION}_linux_amd64 headscale \
    && chmod +x headscale

COPY . ./


FROM alpine:latest
RUN apk update && apk add ca-certificates iptables ip6tables iproute2 && rm -rf /var/cache/apk/* \
    && mkdir -p /etc/headscale

WORKDIR /app

# Copy binary to production image
COPY --from=build /app/start.sh /app/start.sh
COPY --from=build /app/headscale /usr/local/bin/headscale

EXPOSE 8080/tcp

# Run on container startup.
USER root
CMD ["/app/start.sh"]