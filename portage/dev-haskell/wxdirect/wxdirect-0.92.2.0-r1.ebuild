# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.4.7.9999

WX_GTK_VER="3.0"

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="helper tool for building wxHaskell"
HOMEPAGE="https://wiki.haskell.org/WxHaskell"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="${WX_GTK_VER}/${PV}"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-haskell/parsec-2.1.0:=[profile?] <dev-haskell/parsec-4:=[profile?]
	dev-haskell/strict:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.2
"

src_prepare() {
	cabal_chdeps \
		'process    >= 1.1   && < 1.3' 'process    >= 1.1'

	sed -e "s@executable wxdirect@executable wxdirect-${WX_GTK_VER}@" \
		-i "${S}/${PN}.cabal" \
		|| die "Could not change ${PN}.cabal for wxdirect slot ${WX_GTK_VER}"
}
