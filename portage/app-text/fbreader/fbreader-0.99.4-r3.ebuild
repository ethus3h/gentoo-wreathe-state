# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib flag-o-matic

DESCRIPTION="E-Book Reader. Supports many e-book formats"
HOMEPAGE="http://www.fbreader.org/"
SRC_URI="http://www.fbreader.org/files/desktop/${PN}-sources-${PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc x86"
IUSE="debug"

RDEPEND="
	app-arch/bzip2
	dev-libs/expat
	dev-libs/liblinebreak
	dev-libs/fribidi
	dev-db/sqlite
	net-misc/curl
	sys-libs/zlib
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtnetwork:5[ssl]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	# Still use linebreak instead of new unibreak
	sed -e "s:-lunibreak:-llinebreak:" \
		-i makefiles/config.mk zlibrary/text/Makefile || die "fixing libunibreak failed"

	# Let portage decide about the compiler
	sed -e "/^CC = /d" \
		-i makefiles/arch/desktop.mk || die "removing CC line failed"

	# let portage strip the binary
	sed -e '/@strip/d' \
		-i fbreader/desktop/Makefile || die

	# Respect *FLAGS
	sed -e "s/^CFLAGS = -pipe/CFLAGS +=/" \
		-i makefiles/arch/desktop.mk || die "CFLAGS sed failed"
	sed -e "/^	CFLAGS +=/ d" \
		-i makefiles/config.mk || die "CFLAGS sed failed"
	sed -e "/^	LDFLAGS += -s$/ d" \
		-i makefiles/config.mk || die "sed failed"
	sed -e "/^LDFLAGS =$/ d" \
		-i makefiles/arch/desktop.mk || die "sed failed"

	echo "TARGET_ARCH = desktop" > makefiles/target.mk
	echo "LIBDIR = /usr/$(get_libdir)" >> makefiles/target.mk

	echo "UI_TYPE = qt4" >> makefiles/target.mk
	sed -e 's:MOC = moc-qt4:MOC = /usr/bin/moc:' \
		-i makefiles/arch/desktop.mk || die "updating desktop.mk failed"

	if use debug; then
		echo "TARGET_STATUS = debug" >> makefiles/target.mk
	else
		echo "TARGET_STATUS = release" >> makefiles/target.mk
	fi

	# bug #452636
	eapply "${FILESDIR}"/${P}.patch
	# bug #515698
	eapply "${FILESDIR}"/${P}-qreal-cast.patch
	# bug #516794
	eapply "${FILESDIR}"/${P}-mimetypes.patch
	# bug #437262
	eapply "${FILESDIR}"/${P}-ld-bfd.patch
	# bug #592588
	eapply -p0 "${FILESDIR}"/${P}-gcc6.patch

	eapply "${FILESDIR}"/${P}-qt5.patch
	append-cflags -std=c++11

	eapply_user
}

src_compile() {
	# bug #484516
	emake -j1
}

src_install() {
	default
	dosym FBReader /usr/bin/fbreader
}
