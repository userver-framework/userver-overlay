FROM gentoo/stage3:systemd

ENV ACCEPT_KEYWORDS="~amd64"
ENV USE="postgres redis mongodb mysql rabbitmq kafka utest testsuite easy"

RUN emerge-webrsync && mkdir -p /run/lock /run /sys/fs/cgroup

VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
