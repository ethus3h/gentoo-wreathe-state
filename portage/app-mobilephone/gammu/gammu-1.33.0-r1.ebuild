# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils cmake-utils python-single-r1

DESCRIPTION="A tool to handle your cellular phone"
HOMEPAGE="https://wammu.eu/gammu/"
SRC_URI="http://dl.cihar.com/${PN}/releases/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="bluetooth curl dbi debug irda mysql nls postgres python usb"

# TODO: figure out a way to disable gudev
RDEPEND="dev-libs/glib:2=
	virtual/libgudev:=
	bluetooth? ( net-wireless/bluez:= )
	curl? ( net-misc/curl:= )
	dbi? ( >=dev-db/libdbi-0.8.3:= )
	mysql? ( virtual/mysql:= )
	postgres? ( dev-db/postgresql:=[server] )
	python? ( ${PYTHON_DEPS} )
	usb? ( virtual/libusb:1= )
	dev-util/dialog"
DEPEND="${RDEPEND}
	irda? ( virtual/os-headers )
	nls? ( sys-devel/gettext )"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# sys-devel/gettext is needed for creating .mo files
# Supported languages and translated documentation
MY_AVAILABLE_LINGUAS=" af ar bg ca cs da de el en_GB es et fi fr gl he hu id it ko nl pl pt_BR ru sk sv sw tr zh_CN zh_TW"

PATCHES=(
	"${FILESDIR}/${PN}-skip-locktest.patch"
	"${FILESDIR}/${PN}-1.32.0-bashcompdir.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare

	local lang
	for lang in ${MY_AVAILABLE_LINGUAS} ; do
		if ! has ${lang} ${LINGUAS-${lang}} ; then
			rm -rf locale/${lang} || die
		fi
	done
}

src_configure() {
	# debug flag is used inside cmake-utils.eclass
	local mycmakeargs=(
		$(cmake-utils_use_with bluetooth Bluez)
		$(cmake-utils_use_with irda IRDA)
		$(cmake-utils_use_with curl CURL)
		$(cmake-utils_use_with usb USB)
		$(cmake-utils_use_with python PYTHON)
		$(cmake-utils_use_with mysql MySQL)
		$(cmake-utils_use_with postgres Postgres)
		$(cmake-utils_use_with dbi LibDBI)
		$(cmake-utils_use_with nls GettextLibs)
		$(cmake-utils_use_with nls Iconv)
		-DBUILD_SHARED_LIBS=ON
		-DINSTALL_DOC_DIR="share/doc/${PF}"
	)
	if use python; then
		mycmakeargs+=( -DBUILD_PYTHON="${PYTHON}" )
	fi
	cmake-utils_src_configure
}

src_test() {
	LD_LIBRARY_PATH="${WORKDIR}/${PN}_build/common" cmake-utils_src_test
}

src_install() {
	cmake-utils_src_install
	use python && python_optimize
}