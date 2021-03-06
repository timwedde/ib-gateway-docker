# Builder
FROM debian:buster-slim AS builder

RUN apt-get update
RUN apt-get install -y unzip wget curl

WORKDIR /root

RUN wget -q --progress=bar:force:noscroll --show-progress https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh -O install-ibgateway.sh
RUN chmod a+x install-ibgateway.sh

RUN curl -s https://api.github.com/repos/IbcAlpha/IBC/releases/latest | grep browser_download_url | grep -E "(L|l)inux" | cut -d '"' -f 4  | wget -qi - --progress=bar:force:noscroll --show-progress -O ibc.zip
RUN unzip ibc.zip -d /opt/ibc
RUN chmod a+x /opt/ibc/*.sh /opt/ibc/*/*.sh

COPY run.sh run.sh

# Application
FROM debian:buster-slim

RUN apt-get update
RUN apt-get install -y x11vnc xvfb socat

WORKDIR /root

COPY --from=builder /root/install-ibgateway.sh install-ibgateway.sh
RUN yes n | ./install-ibgateway.sh

RUN mkdir .vnc
RUN x11vnc -storepasswd 1358 .vnc/passwd

COPY --from=builder /opt/ibc /opt/ibc
COPY --from=builder /root/run.sh run.sh

COPY ibc_config_prod.ini ibc/config.ini

ENV DISPLAY :0
ENV TWS_PORT 4002
ENV VNC_PORT 5900

CMD ./run.sh
