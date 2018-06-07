# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.9999
#hackport: flags: +bytestring,+containers,+deepseq,+hashable,+tagged,+text,+unordered-containers

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Anything that associates"
HOMEPAGE="https://github.com/ekmett/semigroups/"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE="+binary +transformers"

RDEPEND=">=dev-haskell/bytestring-builder-0.10.4:=[profile?] <dev-haskell/bytestring-builder-1:=[profile?]
	>=dev-haskell/hashable-1.1:=[profile?] <dev-haskell/hashable-1.3:=[profile?]
	>=dev-haskell/nats-0.1:=[profile?] <dev-haskell/nats-2:=[profile?]
	>=dev-haskell/tagged-0.4.4:=[profile?] <dev-haskell/tagged-1:=[profile?]
	>=dev-haskell/text-0.10:=[profile?] <dev-haskell/text-2:=[profile?]
	>=dev-haskell/unordered-containers-0.2:=[profile?] <dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-lang/ghc-7.4.1:=
	binary? ( dev-haskell/binary:=[profile?] )
	transformers? ( >=dev-haskell/transformers-0.2:=[profile?] <dev-haskell/transformers-0.6:=[profile?] )
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.10
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag binary binary) \
		--flag=bytestring \
		--flag=containers \
		--flag=deepseq \
		--flag=hashable \
		--flag=tagged \
		--flag=text \
		$(cabal_flag transformers transformers) \
		--flag=unordered-containers
}
