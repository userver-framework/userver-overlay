# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Production-ready C++ Asynchronous Framework with rich functionality."

HOMEPAGE="https://github.com/userver-framework/userver"

inherit pypi

MAIN_SRC="v3.1.tar.gz"

PYTHON_LIBS=(
  "wheel 0.47.0"
  "typing-extensions 4.16.0"
  "sqlparse 0.5.5"
  "redis 8.0.1"
  "PyMySQL 1.2.0"
  "pygments 2.20.0"
  "propcache 0.5.2"
  "pluggy 1.6.0"
  "packaging 26.2"
  "multidict 6.7.1"
  "iniconfig 2.3.0"
  "idna 3.18"
  "frozenlist 1.8.0"
  "dnspython 2.8.0"
  "crc 7.1.0"
  "cached-property 2.0.1"
  "attrs 26.1.0"
  "async-timeout 5.0.1"
  "aiohappyeyeballs 2.7.1"
  "yarl 1.24.2"
  "pytest 9.1.1"
  "aiosignal 1.4.0"
  "pytest-asyncio 1.4.0"
  "aiormq 6.9.4"
  "pytest-aiohttp 1.1.1"
  "aio-pika 9.6.2"
  "yandex-taxi-testsuite 0.4.7"
  "Jinja2 3.1.6"
  "pydantic 2.13.4"
  "setuptools 82.0.1"
  "annotated-types 0.7.0"
  "typing-inspection 0.4.2"
  "Cython 3.2.8"
  "python-redis 0.4.1"
)

PY2PY3_LIBS=(
  "six 1.17.0"
  "py 1.11.0"
  "python-dateutil 2.9.0.post0"
  "pamqp 3.3.0"
#  "transliterate 1.10.2" (pypi bug; download url: https://files.pythonhosted.org/packages/a1/6e/9a9d597dbdd6d0172427c8cc07c35736471e631060df9e59eeb87687f817/transliterate-1.10.2-py2.py3-none-any.whl )
)

MANYLINUX_PYTHON_LIBS=(
  "pymongo 4.17.0"
  "pyyaml 6.0.3"
  "aiohttp 3.14.1"
# "pydantic_core 2.46.3" (no) (pypi bug; download url: https://files.pythonhosted.org/packages/6c/35/68a762e0c1e31f35fa0dac733cbd9f5b118042853698de9509c8e5bf128b/pydantic_core-2.46.3-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl )
# "pydantic_core 2.46.4" (pypi bug; download url: https://files.pythonhosted.org/packages/07/f8/41db9de19d7987d6b04715a02b3b40aea467000275d9d758ffaa31af7d50/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl )
# "pydantic_core 2.47.0" (no) (pypi bug; download url: https://files.pythonhosted.org/packages/05/9f/b24bb1b764fc360adace5df806a81fd62ef1662df2973891e487c3fd5a2c/pydantic_core-2.47.0-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl )
  "MarkupSafe 3.0.3"
# "psycopg2-binary 2.9.12" (pypi bug; download url: https://files.pythonhosted.org/packages/95/9c/eaa74021ac4e4d5c2f83d82fc6615a63f4fe6c94dc4e94c3990427053f67/psycopg2_binary-2.9.12-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl )
)

PYTHON_SDIST_LIBS=(
  "psycopg2 2.9.12"
  "aiokafka 0.14.0"
  "yandex-pgmigrate 1.0.12"
)

SRC_URI="https://github.com/userver-framework/userver/archive/refs/tags/${MAIN_SRC} -> userver-framework-${MAIN_SRC} https://files.pythonhosted.org/packages/07/f8/41db9de19d7987d6b04715a02b3b40aea467000275d9d758ffaa31af7d50/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl https://files.pythonhosted.org/packages/a1/6e/9a9d597dbdd6d0172427c8cc07c35736471e631060df9e59eeb87687f817/transliterate-1.10.2-py2.py3-none-any.whl https://files.pythonhosted.org/packages/95/9c/eaa74021ac4e4d5c2f83d82fc6615a63f4fe6c94dc4e94c3990427053f67/psycopg2_binary-2.9.12-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"

for dep in "${PYTHON_LIBS[@]}"; do
	set -- ${dep}
	name=$1
	ver=$2
	SRC_URI+=" $(pypi_wheel_url "${name}" "${ver}")"
done

for dep in "${PY2PY3_LIBS[@]}"; do
        set -- ${dep}
        name=$1
        ver=$2
	SRC_URI+=" $(pypi_wheel_url "${name}" "${ver}" "py2.py3")"
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

S="${WORKDIR}/${P}"

CATEGORY="dev-cpp"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64"

#IUSE="grpc grpc-reflection postgres redis redistls mongodb mysql clickhouse rabbitmq kafka rocksdb opentelemetry s3api ydb utest testsuite easy odbc uboost-coro sqlite"

IUSE="postgres redis mongodb mysql rabbitmq kafka utest testsuite easy odbc +uboost-coro sqlite"

#REQUIRED_USE=(
#	"grpc-reflection? ( grpc )"
#	"redistls? ( redis )"
#	"s3api? (grpc)"
#	"opentelemetry? (grpc)"
#	)

#RDEPEND="!dev-cpp/userver-meta dev-util/ruff dev-libs/re2[icu] dev-cpp/cctz dev-libs/cyrus-sasl[static-libs] dev-libs/protobuf app-crypt/mit-krb5 dev-libs/boost dev-cpp/yaml-cpp dev-debug/gdb dev-lang/python[ssl] dev-libs/crypto++[static-libs] dev-libs/jemalloc dev-libs/libbson[static-libs] dev-libs/libev[static-libs] dev-libs/libfmt dev-libs/openssl[static-libs] dev-libs/pugixml dev-libs/re2 dev-python/pip dev-python/voluptuous dev-util/ccache dev-build/cmake dev-build/ninja dev-vcs/git llvm-core/clang net-dns/c-ares[static-libs] net-libs/nghttp2 net-misc/curl[static-libs] net-nds/openldap[static-libs] sys-libs/zlib[static-libs] grpc? ( net-libs/grpc ) postgres? ( dev-db/postgresql[static-libs] ) redis? ( dev-db/redis dev-libs/hiredis[static-libs] ) mongodb? ( dev-db/mongodb dev-libs/mongo-c-driver[static-libs] ) mysql? ( dev-db/mariadb ) rabbitmq? ( dev-cpp/amqp-cpp ) kafka? ( dev-libs/librdkafka ) rocksdb? ( dev-libs/rocksdb[static-libs] ) sqlite? ( dev-db/sqlite ) utest? ( dev-cpp/gtest dev-cpp/benchmark ) ( dev-db/unixODBC[static-libs] ) sqlite? ( dev-db/sqlite )"

RDEPEND="!dev-cpp/userver-meta dev-util/ruff dev-libs/re2[icu] dev-cpp/cctz dev-libs/cyrus-sasl[static-libs] dev-libs/protobuf app-crypt/mit-krb5 >=dev-libs/boost-1.89.0 dev-cpp/yaml-cpp dev-debug/gdb dev-lang/python[ssl] dev-libs/crypto++[static-libs] dev-libs/jemalloc dev-libs/libbson[static-libs] dev-libs/libev[static-libs] dev-libs/libfmt dev-libs/openssl[static-libs] dev-libs/pugixml dev-libs/re2 dev-python/pip dev-python/voluptuous dev-util/ccache dev-build/cmake dev-build/ninja dev-vcs/git llvm-core/clang net-dns/c-ares[static-libs] net-libs/nghttp2 net-misc/curl[static-libs] net-nds/openldap[static-libs] sys-libs/zlib[static-libs] postgres? ( dev-db/postgresql[static-libs] ) redis? ( dev-db/redis dev-libs/hiredis[static-libs] ) mongodb? ( >=dev-db/mongodb-8.0.12 dev-libs/mongo-c-driver[static-libs] ) mysql? ( dev-db/mariadb ) rabbitmq? ( dev-cpp/amqp-cpp ) kafka? ( dev-libs/librdkafka ) sqlite? ( dev-db/sqlite ) utest? ( dev-cpp/gtest dev-cpp/benchmark ) odbc? ( dev-db/unixODBC[static-libs] ) sqlite? ( dev-db/sqlite )"

DEPEND="${RDEPEND}"

BDEPEND=""

src_unpack(){
    unpack "${DISTDIR}/userver-framework-${MAIN_SRC}" || die "unable to unpack source code"
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


src_prepare() {
  eapply_user
}

src_configure() {
	cmake -S${S}/ -B build_debug -DCMAKE_BUILD_TYPE=Debug -DUSERVER_INSTALL=ON -DUSERVER_SANITIZE="ub addr" -DUSERVER_DOWNLOAD_PACKAGES=OFF -DUSERVER_CHECK_PACKAGE_VERSIONS=OFF -DUSERVER_PIP_OPTIONS="--no-index;--find-links=${S}/third_party/wheelhouse" -DUSERVER_FEATURE_STACKTRACE=OFF -DUSERVER_FEATURE_CHAOTIC=ON -DUSERVER_FEATURE_GRPC=OFF -DUSERVER_FEATURE_GRPC_REFLECTION=OFF -DUSERVER_FEATURE_POSTGRESQL=$(usex postgres) -DUSERVER_FEATURE_REDIS=$(usex redis) -DUSERVER_FEATURE_REDIS_TLS=OFF -DUSERVER_FEATURE_MONGODB=$(usex mongodb) -DUSERVER_FEATURE_MYSQL=$(usex mysql) -DUSERVER_FEATURE_CLICKHOUSE=OFF -DUSERVER_FEATURE_RABBITMQ=$(usex rabbitmq) -DUSERVER_FEATURE_KAFKA=$(usex kafka) -DUSERVER_FEATURE_ROCKS=OFF -DUSERVER_FEATURE_OTLP=OFF -DUSERVER_FEATURE_S3API=OFF -DUSERVER_FEATURE_YDB=OFF -DUSERVER_FEATURE_UTEST=$(usex utest) -DUSERVER_FEATURE_TESTSUITE=$(usex testsuite) -DUSERVER_FEATURE_EASY=$(usex easy) -DUSERVER_FEATURE_ODBC=$(usex odbc) -DUSERVER_FEATURE_UBOOST_CORO=$(usex uboost-coro) -DUSERVER_FEATURE_SQLITE=$(usex sqlite) -GNinja || die "unable to configure debug version"

	cmake -S${S}/ -B build_release -DCMAKE_BUILD_TYPE=Release -DUSERVER_INSTALL=ON -DUSERVER_SANITIZE="" -DUSERVER_DOWNLOAD_PACKAGES=OFF -DUSERVER_CHECK_PACKAGE_VERSIONS=OFF -DUSERVER_PIP_OPTIONS="--no-index;--find-links=${S}/third_party/wheelhouse" -DUSERVER_FEATURE_STACKTRACE=OFF -DUSERVER_FEATURE_CHAOTIC=ON -DUSERVER_FEATURE_GRPC=OFF -DUSERVER_FEATURE_GRPC_REFLECTION=OFF -DUSERVER_FEATURE_POSTGRESQL=$(usex postgres) -DUSERVER_FEATURE_REDIS=$(usex redis) -DUSERVER_FEATURE_REDIS_TLS=OFF -DUSERVER_FEATURE_MONGODB=$(usex mongodb) -DUSERVER_FEATURE_MYSQL=$(usex mysql) -DUSERVER_FEATURE_CLICKHOUSE=OFF -DUSERVER_FEATURE_RABBITMQ=$(usex rabbitmq) -DUSERVER_FEATURE_KAFKA=$(usex kafka) -DUSERVER_FEATURE_ROCKS=OFF -DUSERVER_FEATURE_OTLP=OFF -DUSERVER_FEATURE_S3API=OFF -DUSERVER_FEATURE_YDB=OFF -DUSERVER_FEATURE_UTEST=$(usex utest) -DUSERVER_FEATURE_TESTSUITE=$(usex testsuite) -DUSERVER_FEATURE_EASY=$(usex easy) -DUSERVER_FEATURE_ODBC=$(usex odbc) -DUSERVER_FEATURE_UBOOST_CORO=$(usex uboost-coro) -DUSERVER_FEATURE_SQLITE=$(usex sqlite) -GNinja || die "unable to configure release version"
}

src_compile() {
	cmake --build "${S}/build_debug" -- -j$(nproc) || die "unable to build debug version"
	cmake --build "${S}/build_release" -- -j$(nproc) || die "unable to build release version"
}

src_install() {
        dodir /usr || die "unable to create temporary install directory"
        dodir /userver || die "unable to create intermediate temporary install directory"
        cmake --install "${S}/build_debug/" --prefix "${D}/userver" || die "unable to install to intermediate temporary directory"
        cmake --install "${S}/build_release/" --prefix "${D}/userver" || die "unable to install to intermediate temporary directory"
        cp -a "${D}/userver/." "${D}/usr" || die "unable to install"
        rm -rf "${D}/userver"
}

pkg_postinst(){
	rm -rf "${S}/build_debug/" "${S}/build_release/"
	ccache --clear
}
