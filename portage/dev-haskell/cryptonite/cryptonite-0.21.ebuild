# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.1.9999
#hackport: flags: -check_alignment,-old_toolchain_inliner

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Cryptography Primitives sink"
HOMEPAGE="https://github.com/haskell-crypto/cryptonite"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE="+integer-gmp +support_aesni support_blake2_sse +support_deepseq support_pclmuldq +support_rdrand"

RDEPEND=">=dev-haskell/memory-0.8:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.10
	test? ( dev-haskell/byteable
		dev-haskell/tasty
		dev-haskell/tasty-hunit
		dev-haskell/tasty-kat
		dev-haskell/tasty-quickcheck )
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=-check_alignment \
		$(cabal_flag integer-gmp integer-gmp) \
		--flag=-old_toolchain_inliner \
		$(cabal_flag support_aesni support_aesni) \
		$(cabal_flag support_blake2_sse support_blake2_sse) \
		$(cabal_flag support_deepseq support_deepseq) \
		$(cabal_flag support_pclmuldq support_pclmuldq) \
		$(cabal_flag support_rdrand support_rdrand)
}
