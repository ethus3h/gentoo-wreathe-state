# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit distutils-r1

DESCRIPTION="Common tools and data structures implemented in pure python"
HOMEPAGE="https://pypi.org/project/common/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="all-rights-reserved"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux"
IUSE=""

RESTRICT="mirror bindist"
