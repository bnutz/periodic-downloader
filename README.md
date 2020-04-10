# bnutz/periodic-downloader
Periodically download urls to a target folder on a cron schedule

DESCRIPTION:
-----------
A simple Docker container to download fixed links to a target folder at given intervals.

Links are downloaded via the syntax: `curl {options} -O {link}`

Multiple links supported (separate each link with a semi-colon)

This container uses the pre-configured `crond` schedules in BusyBox to run its jobs (as discovered in [this gist comment](https://gist.github.com/andyshinn/3ae01fa13cb64c9d36e7#gistcomment-2044506))
```
bash-5.0# crontab -l
# do daily/weekly/monthly maintenance
# min   hour    day     month   weekday command
*/15    *       *       *       *       run-parts /etc/periodic/15min
0       *       *       *       *       run-parts /etc/periodic/hourly
0       2       *       *       *       run-parts /etc/periodic/daily
0       3       *       *       6       run-parts /etc/periodic/weekly
0       5       1       *       *       run-parts /etc/periodic/monthly
```

Handy if you just want to download at generic timeframes, and not too fussed at exactly *when* the download happens.

If you need more control over timing, try this container instead: https://github.com/jsonfry/docker-curl-cron


EXAMPLE USAGE:
-------

```
docker run \
    --name=periodic-downloader \
    -e PUID=1000 \
    -e PGID=1000 \
    -e DOWNLOAD_URLS_WEEKLY="http://server1/backup1.zip;http://server2/backup2.zip" \
    -e CURL_OPTIONS="--remote-header-name --verbose" \
    -e DEBUG=false \
    -v <path to downloads folder>:/download \
    bnutz/periodic-downloader
```

DOCKER PARAMETERS:
------------------

| Default Parameters | Function |
| ------------------ | -------- |
| `-e PUID=1000`   | Set UID for downloaded files. |
| `-e PGID=1000`   | Set GID for downloaded files. |
| `-e DOWNLOAD_URLS_15MIN=""`  | Semi-colon separated list of urls to download every 15 mins. Leave empty to skip. |
| `-e DOWNLOAD_URLS_HOURLY=""`  | List of urls to download every hour. |
| `-e DOWNLOAD_URLS_DAILY=""`  | List of urls to download every day. |
| `-e DOWNLOAD_URLS_WEEKLY=""`  | List of urls to download every week. |
| `-e DOWNLOAD_URLS_MONTHLY=""`  | List of urls to download every month. |
| `-e CURL_OPTIONS="-J"`  | Include these options when executing the `curl` command (`-O` will always be included). |
| `-e DEBUG=false` | Set debug logging (when `true`, prints the commands instead of executing them). |
| `-v /path/to/downloads/folder:/download` | Path to downloads folder on host machine. |
