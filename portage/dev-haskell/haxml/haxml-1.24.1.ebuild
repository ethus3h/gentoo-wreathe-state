# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.3.6.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit haskell-cabal

MY_PN="HaXml"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Utilities for manipulating XML documents"
HOMEPAGE="https://archives.haskell.org/projects.haskell.org/HaXml/"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-haskell/polyparse-1.9:=[profile?]
	dev-haskell/random:=[profile?]
	>=dev-lang/ghc-6.10.4:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.6.0.3
"

S="${WORKDIR}/${MY_P}"
