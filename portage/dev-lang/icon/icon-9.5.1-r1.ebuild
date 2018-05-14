# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic toolchain-funcs

DESCRIPTION="very high level language"
HOMEPAGE="http://www.cs.arizona.edu/icon/"

MY_PV=${PV//./}
SRC_URI="http://www.cs.arizona.edu/icon/ftp/packages/unix/icon-v${MY_PV}src.tgz"

LICENSE="public-domain HPND"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ia64 ~ppc ~ppc64 ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="X iplsrc"

S="${WORKDIR}/icon-v${MY_PV}src"

RDEPEND="
	X? ( x11-libs/libX11:= )"
DEPEND="
	${RDEPEND}
	X? (
		x11-libs/libXpm
		x11-libs/libXt
	)"

PATCHES=( "${FILESDIR}"/${PN}-9.5.1-flags.patch )

src_prepare() {
	default

	# do not prestrip files
	find src -name 'Makefile' | xargs sed -i -e "/strip/d" || die
}

src_configure() {
	# select the right compile target.  Note there are many platforms
	# available
	local mytarget;
	if [[ ${CHOST} == *-darwin* ]]; then
		mytarget="macintosh"
	else
		mytarget="linux"
	fi

	# Fails if more then one make job process.
	# This is an upstream requirement.
	emake -j1 $(usex X X-Configure Configure) name=${mytarget}

	# sanitise the Makedefs file generated by Configure
	sed -i \
		-e 's:-L/usr/X11R6/lib64::g' \
		-e 's:-L/usr/X11R6/lib::g' \
		-e 's:-I/usr/X11R6/include::g' \
		Makedefs || die "sed of Makedefs failed"

	append-flags $(test-flags -fno-strict-aliasing -fwrapv)
}

src_compile() {
	# Fails if more then one make job process.
	# This is an upstream requirement.
	emake -j1 CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_test() {
	emake Samples
	emake Test
}

src_install() {
	# Needed for make Install
	dodir /usr/$(get_libdir)

	emake Install dest="${D}/usr/$(get_libdir)/icon"
	dosym ../$(get_libdir)/icon/bin/icont /usr/bin/icont
	dosym ../$(get_libdir)/icon/bin/iconx /usr/bin/iconx
	dosym ../$(get_libdir)/icon/bin/icon  /usr/bin/icon
	dosym ../$(get_libdir)/icon/bin/vib   /usr/bin/vib

	cd "${S}/man/man1" || die
	doman "${PN}"t.1
	doman "${PN}".1

	cd "${S}/doc" || die
	DOCS=( *.txt ../README )

	HTML_DOCS=( *.{htm,gif,jpg,css} )
	einstalldocs

	# Clean up items from make Install that get installed elsewhere
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}/man || die
	rm -rf "${ED}"/usr/$(get_libdir)/icon/{doc,README} || die

	# optional Icon Programming Library
	if use iplsrc; then
		cd "${S}" || die

		# Remove unneeded files before copy
		rm -fv ipl/{BuildBin,BuildExe,CheckAll,Makefile} || die

		insinto /usr/$(get_libdir)/icon
		doins -r ipl
	fi
}
