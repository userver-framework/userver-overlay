FROM gentoo/stage3:systemd

RUN emerge-webrsync && mkdir -p /run/lock /run /sys/fs/cgroup

VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
