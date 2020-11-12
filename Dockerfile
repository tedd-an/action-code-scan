FROM blueztestbot/bluez-build:latest

COPY *.sh /
COPY coverity-submit /
COPY send-email /
COPY *.cfg /

ENTRYPOINT [ "/entrypoint.sh" ]
