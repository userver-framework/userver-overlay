FROM gentoo/stage3:systemd

ENV ACCEPT_KEYWORDS="~amd64"

RUN emerge-webrsync && mkdir -p /run/lock /run /sys/fs/cgroup

VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
