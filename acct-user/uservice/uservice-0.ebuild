# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DEPEND="acct-group/uservice"

RDEPEND="acct-group/uservice"

DESCRIPTION="User for MyCustomService"
ACCT_USER_ID=558
ACCT_USER_GROUPS=( uservice )
ACCT_USER_SHELL="/sbin/nologin"
ACCT_USER_HOME="/dev/null"

acct-user_add_deps
