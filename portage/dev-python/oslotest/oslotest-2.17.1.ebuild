# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="Oslo test framework"
HOMEPAGE="https://launchpad.net/oslo"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm64 x86 ~amd64-linux ~x86-linux"
IUSE="doc test"

CDEPEND=">=dev-python/pbr-1.8[${PYTHON_USEDEP}]"
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	${CDEPEND}
	test? (
		>=dev-python/oslo-config-4.0.0[${PYTHON_USEDEP}]
		!~dev-python/oslo-config-4.3.0[${PYTHON_USEDEP}]
		!~dev-python/oslo-config-4.4.0[${PYTHON_USEDEP}]
	)
	doc? (
		>=dev-python/openstackdocstheme-1.16.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-1.6.2[${PYTHON_USEDEP}]
		>=dev-python/reno-1.8.0[${PYTHON_USEDEP}]
		!~dev-python/reno-2.3.1[${PYTHON_USEDEP}]
	)
"
RDEPEND="
	>=dev-python/fixtures-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/subunit-0.0.18[${PYTHON_USEDEP}]
	>=dev-python/six-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/testrepository-0.0.18[${PYTHON_USEDEP}]
	>=dev-python/testtools-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/mock-2.0[${PYTHON_USEDEP}]
	>=dev-python/mox3-0.7.0[${PYTHON_USEDEP}]
	!~dev-python/mox3-0.19.0[${PYTHON_USEDEP}]
	>=dev-python/os-client-config-1.28.0[${PYTHON_USEDEP}]
	>=dev-python/debtcollector-1.2.0[${PYTHON_USEDEP}]
"

python_compile_all() {
	if use doc; then
		esetup.py build_sphinx -b man
	fi
}

python_test() {
	rm -rf .testrepository || die "couldn't remove '.testrepository' under ${EPYTHON}"

	testr init || die "testr init failed under ${EPYTHON}"
	testr run || die "testr run failed under ${EPYTHON}"
}

python_install_all() {
	if use doc; then
		doman doc/build/man/oslotest.1
	fi

	distutils-r1_python_install_all
}
