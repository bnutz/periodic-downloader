FROM alpine:3

RUN apk add --no-cache bash curl

SHELL ["/bin/bash", "-c"]

WORKDIR /root

VOLUME /download

ENV DEBUG="false"

ENV PUID=1000
ENV PGID=1000

# Semi-colon separated list of urls. Leave empty to skip.
ENV DOWNLOAD_URLS_15MIN=""
ENV DOWNLOAD_URLS_HOURLY=""
ENV DOWNLOAD_URLS_DAILY=""
ENV DOWNLOAD_URLS_WEEKLY=""
ENV DOWNLOAD_URLS_MONTHLY=""

# Reference https://gist.github.com/andyshinn/3ae01fa13cb64c9d36e7#gistcomment-2044506
COPY run_15 /etc/periodic/15min/run_15
COPY run_hourly /etc/periodic/hourly/run_hourly
COPY run_daily /etc/periodic/daily/run_daily
COPY run_weekly /etc/periodic/weekly/run_weekly
COPY run_monthly /etc/periodic/monthly/run_monthly

RUN chmod +x /etc/periodic/15min/run_15
RUN chmod +x /etc/periodic/hourly/run_hourly
RUN chmod +x /etc/periodic/daily/run_daily
RUN chmod +x /etc/periodic/weekly/run_weekly
RUN chmod +x /etc/periodic/monthly/run_monthly

COPY download_urls.sh .
RUN chmod +x download_urls.sh

# Reference: https://unix.stackexchange.com/q/412805
CMD crond -l 2 -f

# For debugging
# CMD tail -f /dev/null
