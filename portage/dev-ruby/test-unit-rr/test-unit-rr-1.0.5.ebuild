# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby21 ruby22 ruby23 ruby24"

RUBY_FAKEGEM_TASK_TEST=""

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="RR adapter for Test::Unit"
HOMEPAGE="https://github.com/test-unit/test-unit-rr"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 ~hppa ia64 ppc ppc64 sparc x86"
IUSE=""

ruby_add_rdepend ">=dev-ruby/rr-1.1.1 >=dev-ruby/test-unit-2.5.2"

each_ruby_test() {
	${RUBY} test/run-test.rb || die
}