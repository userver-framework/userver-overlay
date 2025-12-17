FROM gentoo/stage3:systemd

ENV ACCEPT_KEYWORDS="~amd64"
ENV USE="postgres redis mongodb mysql rabbitmq kafka utest testsute easy"

RUN emerge-webrsync 
    && mkdir -p /run/lock /run /sys/fs/cgroup

RUN emerge -v app-portage/eselect-repository 
    && eselect repository add userver-framework git https://github.com/userver-framework/userver-overlay.git 
    && emaint -a sync >/dev/null 2>&1 || true

VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
