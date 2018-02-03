# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils qmake-utils

DESCRIPTION="Graphical interface for the ClustalW multiple alignment program"
HOMEPAGE="http://www.ebi.ac.uk/tools/clustalw2/"
SRC_URI="
	http://www.clustal.org/download/current/${P}.tar.gz
	https://dev.gentoo.org/~jlec/distfiles/${PN}.png.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4"
RDEPEND="${DEPEND}
	>=sci-biology/clustalw-${PV}"

src_prepare() {
	sed \
		-e "s|colprot.xml|${EPREFIX}/usr/share/${PN}/colprot.xml|" \
		-e "s|coldna.xml|${EPREFIX}/usr/share/${PN}/coldna.xml|" \
		-e "s|colprint.xml|${EPREFIX}/usr/share/${PN}/colprint.xml|" \
		-i ClustalQtParams.h || \
		die "Failed to patch shared files location."
	sed \
		-e "s|clustalx.hlp|${EPREFIX}/usr/share/${PN}/clustalx.hlp|" \
		-i HelpDisplayWidget.cpp || \
		die "Failed to patch help file location."
	rm -rf usr || die
	default
}

src_configure() {
	eqmake4
}

src_install() {
	dobin clustalx
	insinto /usr/share/${PN}
	doins colprot.xml coldna.xml colprint.xml clustalx.hlp
	make_desktop_entry ${PN} ClustalX
	doicon "${WORKDIR}"/${PN}.png
}