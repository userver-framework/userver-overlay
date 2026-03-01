# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="The service to control dynamic configs of other userver-based services"

HOMEPAGE="https://github.com/userver-framework/uservice-dynconf"

SRC_URI="https://github.com/userver-framework/uservice-dynconf/archive/refs/tags/v2.13.tar.gz -> uservice-dynconf-2.13.tar.gz"

S="${WORKDIR}/${P}"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64"

IUSE=""

RDEPEND="dev-db/postgresql[static-libs] acct-user/uservice"

BDEPEND="dev-cpp/userver[postgres]"

src_compile() {
	cd "${S}/"
	emake build-release
}

src_install(){
	dodir /usr
	dodir /etc/uservice-dynconf
	dodir /usr/share/uservice-dynconf/schemas/
	dodir /usr/share/uservice-dynconf/data/
	emake prefix="/usr" DESTDIR="${D}" install
	cp "${S}/postgresql/schemas/uservice_dynconf.sql" "${D}/usr/share/uservice-dynconf/schemas/uservice_dynconf.sql"
	cp "${S}/postgresql/data/default_configs.sql" "${D}/usr/share/uservice-dynconf/data/default_configs.sql"
	cp "${S}/configs/config_vars.yaml" "${D}/etc/uservice-dynconf/config_vars.yaml"
	systemd_dounit "${FILESDIR}"/uservice-dynconf.service
	doinitd "${FILESDIR}/uservice-dynconf"
}

pkg_postinst(){
	elog "you must run \"emerge --config dev-db/postgresql\" and \"emerge --config app-servers/uservice-dynconf\" to use it!"
}

pkg_config(){
    einfo "Checking PostgreSQL service…"

    # systemd case
    if command -v systemctl >/dev/null 2>&1 ; then
        einfo "Detected systemd"
        if ! systemctl is-active --quiet postgresql.service ; then
            einfo "PostgreSQL not active — starting…"
            if ! systemctl start postgresql.service ; then
                die "Failed to start PostgreSQL via systemctl"
            fi
        fi

    # OpenRC case
    elif command -v rc-service >/dev/null 2>&1 ; then
        einfo "Detected OpenRC"
        if ! rc-service postgresql status >/dev/null 2>&1 ; then
            einfo "PostgreSQL not active — starting…"
            if ! rc-service postgresql start ; then
                die "Failed to start PostgreSQL via OpenRC"
            fi
        fi

    else
        die "Unknown init system — cannot manage PostgreSQL"
    fi
    # Делаем паузу, чтобы служба успела подняться
    sleep 20

    # Проверка доступности сервера
    if ! su - postgres -c "psql -Atc '\\l'" >/dev/null 2>&1 ; then
        die "PostgreSQL is not responding to connections"
    fi

    einfo "PostgreSQL is running — ensuring role/database…"

    # создать роль uservice_dynconf если не существует
    su - postgres -c \
        "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='uservice_dynconf'\"" \
        | grep -q 1 || \
    su - postgres -c \
        "psql -c \"CREATE ROLE uservice_dynconf WITH LOGIN PASSWORD 'password'\"" || \
        die "Failed to create role uservice_dynconf"

    # создать базу uservice_dynconf если её нет
    su - postgres -c \
        "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='uservice_dynconf'\"" \
        | grep -q 1 || \
    su - postgres -c \
        "psql -c \"CREATE DATABASE uservice_dynconf OWNER uservice_dynconf\"" || \
        die "Failed to create database uservice_dynconf"

    einfo "Applying SQL schema files…"

    # выполнить SQL файлы
    su - postgres -c \
        "psql -d uservice_dynconf -f /usr/share/uservice-dynconf/schemas/uservice_dynconf.sql" || \
        die "Failed to apply uservice_dynconf schema"

    su - postgres -c \
        "psql -d uservice_dynconf -f /usr/share/uservice-dynconf/data/default_configs.sql" || \
        die "Failed to apply default_configs"

    einfo "Uservice-DynConf setup completed."

}
