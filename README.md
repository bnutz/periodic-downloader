# bnutz/periodic-downloader
Periodically download urls to a target folder on a cron schedule

DESCRIPTION:
-----------
A simple Docker container to download fixed links to a target folder at given intervals.

Can choose to download via `curl` or via `wget`. Syntax used will be one of the following:
* `curl {options} -O {link}` (default)
* `wget {options} {link}`

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
    -e CURL_OPTIONS="-J -v" \
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
| `-e DOWNLOADER="curl"`  | Enter either `curl` or `wget` to set the download command. |
| `-e CURL_OPTIONS="--compressed"`  | Include these options when executing the `curl` command (`-O` will always be included). |
| `-e WGET_OPTIONS="--content-disposition --backups=1"`  | Include these options when executing the `wget` command. |
| `-e WGET_DELETE_BACKUP_1=false`  | When using `wget`, delete `*.1` backup files when done (Handle with care; only use when `--backups=1` is active. See **Notes** below). |
| `-e DEBUG=false` | Set debug logging (when `true`, prints the download commands instead of executing them). |
| `-v /path/to/downloads/folder:/download` | Path to downloads folder on host machine. |

NOTES:
------
* Neither `curl` nor `wget` will overwrite an existing file by default:
  * `curl` will only overwrite when using the `-O, --remote-name` option... *except* [when `-J, --remote-header-name` is also active](https://curl.haxx.se/docs/manpage.html#-J).
  * `wget` will also only overwrite when using the `-O filename, --output-document=filename`, *however* this option requires you to [specify a filename in advance](https://www.gnu.org/software/wget/manual/wget.html#Download-Options).
* So for `curl`, as long as we avoid using the `-J` option; we can get the periodic backup behaviour and only keep the most recent file.
* If we do have a link that uses the `Content-Disposition` header and saves to a different filename (like if clicking on "ht<span>tp://si</span>te.<span>com/page?ex</span>port" saves to *filename.pdf*):
  * Then we can use `wget` with the following options:<p>`wget --content-disposition --backups=1 {link}`</p>
    * `--content-disposition` will allow us to save as the intended filename set by the server.
    * `--backups=1` means if the file exists, `wget` will add `.1` to its filename before downloading the new file in its place (See the [man page](https://www.gnu.org/software/wget/manual/wget.html#Download-Options) for more info).
  * When using the `--backups` option - there will be two files:
    * *filename.ext* - The latest version of the downloaded file
    * *filename.ext.1* - The previous version of the downloaded file
  * If you don't want two copies of the file, then can set the environment variable `WGET_DELETE_BACKUP_1=true` to delete the previous copy of the file after download is complete.
    * **Be careful with this option** - all it does is run "`rm *.1`" in the download folder; it does **not** do any checking or verification.
