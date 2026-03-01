# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd pypi

DESCRIPTION="The service to control dynamic configs of other userver-based services"

HOMEPAGE="https://github.com/userver-framework/uservice-dynconf"

MAIN_SRC="uservice-dynconf-2.13.tar.gz"

SRC_URI="https://github.com/userver-framework/uservice-dynconf/archive/refs/tags/v2.13.tar.gz -> ${MAIN_SRC}"

PYTHON_LIBS=(
    "aio-pika 9.6.1"
    "aiohappyeyeballs 2.6.1"
    "aiormq 6.9.3"
    "aiosignal 1.4.0"
    "async-timeout 5.0.1"
    "attrs 25.4.0"
    "cached-property 2.0.1"
    "crc 7.1.0"
    "dnspython 2.8.0"
    "frozenlist 1.8.0"
    "idna 3.11"
    "Jinja2 3.1.6"
    "packaging 26.0"
    "pytest 9.0.2"
    "pytest-aiohttp 1.1.0"
    "pytest-asyncio 1.3.0"
    "wheel 0.46.3"
    "yandex-taxi-testsuite 0.4.5"
    "yarl 1.22.0"
)

MANYLINUX_PYTHON_LIBS=(
    "aiohttp 3.13.3"
    "pymongo 4.16.0"
)

PYTHON_SDIST_LIBS=(
    "aiokafka 0.13.0"
    "MarkupSafe 3.0.3"
    "python-redis 0.4.0"
    "yandex-pgmigrate 1.0.11"
)

PY2PY3_LIBS=(
    "python-dateutil 2.9.0.post0"
)

for dep in "${PYTHON_LIBS[@]}"; do
        set -- ${dep}
        name=$1
        ver=$2
        SRC_URI+=" $(pypi_wheel_url "${name}" "${ver}")"
done

for dep in "${MANYLINUX_PYTHON_LIBS[@]}"; do
        set -- ${dep}
        name=$1
        ver=$2
	SRC_URI+=" $(pypi_wheel_url "${name}" "${ver}" "cp313" "cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64")"
done

for dep in "${PYTHON_SDIST_LIBS[@]}"; do
        set -- ${dep}
        name=$1
        ver=$2
	SRC_URI+=" $(pypi_sdist_url "${name}" "${ver}")"
done

for dep in "${PY2PY3_LIBS[@]}"; do
        set -- ${dep}
        name=$1
        ver=$2
        SRC_URI+=" $(pypi_wheel_url "${name}" "${ver}" "py2.py3")"
done

S="${WORKDIR}/${P}"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64"

IUSE=""

RDEPEND="dev-db/postgresql[static-libs] acct-user/uservice"

BDEPEND="dev-cpp/userver[postgres]"

src_unpack(){
    unpack "${DISTDIR}/${MAIN_SRC}" || die "unable to unpack source code"
    cd "${S}" || die "unable to enter source code directory"

    # Создаём директорию third_party
    mkdir -p "${S}/third_party" || die "unable to create third_party directory"
    
    # Переходим в third_party и распаковываем
    cd "${S}/third_party" || die "unable to enter third-party directory"

    # Создаём wheelhouse для python пакетов
    mkdir "wheelhouse" || die "unable to create directory for python packages"
    
    # Копируем остальные файлы в wheelhouse
    for file in ${A}; do
        if [[ ${file} != ${MAIN_SRC} ]]; then
            cp "${DISTDIR}/${file}" "${S}/third_party/wheelhouse" || die "unable to copy ${file} to wheelhouse directory"
        fi
    done
}

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
