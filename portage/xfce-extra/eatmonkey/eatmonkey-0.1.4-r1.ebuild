# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils

DESCRIPTION="A download manager that works exclusively with aria2"
HOMEPAGE="https://goodies.xfce.org/projects/applications/eatmonkey"
SRC_URI="mirror://xfce/src/apps/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND=">=x11-libs/gtk+-2.12:2
	dev-libs/libunique:1
	>=xfce-base/libxfce4util-4.8
	>=net-libs/libsoup-2.26:2.4"
RDEPEND="${COMMON_DEPEND}
	>=net-misc/aria2-1.9.0[bittorrent,xmlrpc]
	dev-lang/ruby
	dev-ruby/ruby-glib2
	dev-ruby/ruby-gtk2"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog NEWS README )

src_prepare() {
	eapply -p0 "${FILESDIR}"/${P}-syntax.patch
	sed -i -e 's:/usr/local:/usr:' src/eat{monkey,manager.rb} || die
	default
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
