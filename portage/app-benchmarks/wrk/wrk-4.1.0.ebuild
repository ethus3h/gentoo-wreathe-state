# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="A modern HTTP benchmarking tool"
HOMEPAGE="https://github.com/wg/wrk"
SRC_URI="https://github.com/wg/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="libressl"

DEPEND=">=dev-lang/luajit-2.0.2
	dev-lang/lua:0
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )"
RDEPEND="${DEPEND}"

src_prepare() {
	rm -rf deps/ || die "failed to remove bundled dependencies"
	epatch "${FILESDIR}/${PN}-4.1.0-makefile.patch"
}

src_compile() {
	tc-export CC
	emake
}

src_install() {
	dobin ${PN}
	dodoc README.md NOTICE
	insinto /usr/share/${PN}
	doins -r scripts
}
