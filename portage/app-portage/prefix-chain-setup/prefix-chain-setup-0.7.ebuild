# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit prefix

DESCRIPTION="Chained EPREFIX bootstrapping utility"
HOMEPAGE="https://prefix.gentoo.org/"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/portage[prefix-chaining]"

S="${WORKDIR}"

src_install() {
	eprefixify ${PN}
	sed -e "s,@GENTOO_PORTAGE_CHOST@,${CHOST}," -i ${PN}
	dobin ${PN}
}

src_unpack() {
	{ cat > "${PN}" || die; } <<'EOF'
#!/usr/bin/env bash

PARENT_EPREFIX="@GENTOO_PORTAGE_EPREFIX@"
PARENT_CHOST="@GENTOO_PORTAGE_CHOST@"
CHILD_EPREFIX=
CHILD_PROFILE=
DO_MINIMAL=no
DO_SOURCES=no
PORT_TMPDIR=

#
# get ourselfs the functions.sh script for ebegin/eend/etc.
#
for f in \
	/lib/gentoo/functions.sh \
	/etc/init.d/functions.sh \
	/sbin/functions.sh \
; do
	if [[ -r ${PARENT_EPREFIX}${f} ]]; then
		. "${PARENT_EPREFIX}${f}"
		f=found
		break
	fi
done

if [[ ${f} != found ]]; then
	echo "Cannot find Gentoo functions, aborting." >&2
	exit 1
fi

for arg in "$@"; do
	case "${arg}" in
	--eprefix=*)	CHILD_EPREFIX="${arg#--eprefix=}"	;;
	--profile=*)	CHILD_PROFILE="${arg#--profile=}"	;;
	--sources)		DO_SOURCES=yes						;;
	--portage-tmpdir=*)	PORT_TMPDIR="${arg#--portage-tmpdir=}" ;;

	--help)
		einfo "$0 usage:"
		einfo "  --eprefix=[PATH]       Path to new EPREFIX to create chained to the prefix"
		einfo "                         where this script is installed (${PARENT_EPREFIX})"
		einfo "  --profile=[PATH]       The absolute path to the profile to use. This path"
		einfo "                         must point to a directory within ${PARENT_EPREFIX}"
		einfo "  --sources              inherit 'source' statements from the parent make.conf"
		einfo "  --portage-tmpdir=DIR   use DIR as portage temporary directory."
		exit 0
		;;
	esac
done

#
# sanity check of given values
#

test -n "${CHILD_EPREFIX}" || { eerror "no eprefix argument given"; exit 1; }
test -d "${CHILD_EPREFIX}" && { eerror "${CHILD_EPREFIX} already exists"; exit 1; }
test -n "${CHILD_PROFILE}" || { eerror "no profile argument given"; exit 1; }
test -d "${CHILD_PROFILE}" || { eerror "${CHILD_PROFILE} does not exist"; exit 1; }
if test -n "${PORT_TMPDIR}"; then
	if ! test -d "${PORT_TMPDIR}"; then
		einfo "creating temporary directory ${PORT_TMPDIR}"
		mkdir -p "${PORT_TMPDIR}"
	fi
fi

einfo "creating chained prefix ${CHILD_EPREFIX}"

#
# functions needed below.
#
eend_exit() {
	eend $1
	[[ $1 != 0 ]] && exit 1
}

#
# create the directories required to bootstrap the least.
#
ebegin "creating directory structure"
(
	set -e
	mkdir -p "${CHILD_EPREFIX}"/etc/portage/profile/use.mask
	mkdir -p "${CHILD_EPREFIX}"/etc/portage/profile/use.force
	mkdir -p "${CHILD_EPREFIX}"/var/log
)
eend_exit $?

#
# create a make.conf and set PORTDIR and PORTAGE_TMPDIR
#
ebegin "creating make.conf"
(
	set -e
	echo "#"
	echo "# The following values where taken from the parent prefix's"
	echo "# environment. Feel free to adopt them as you like."
	echo "#"
	echo "CFLAGS=\"$(portageq envvar CFLAGS)\""
	echo "CXXFLAGS=\"$(portageq envvar CXXFLAGS)\""
	echo "MAKEOPTS=\"$(portageq envvar MAKEOPTS)\""
	niceness=$(portageq envvar PORTAGE_NICENESS || true)
	[[ -n ${niceness} ]] &&
		echo "PORTAGE_NICENESS=\"${niceness}\""
	echo "USE=\"prefix-chain\""
	echo
	echo "# Mirrors from parent prefix."
	echo "GENTOO_MIRRORS=\"$(portageq envvar GENTOO_MIRRORS || true)\""
	echo
	echo "#"
	echo "# Below comes the chained-prefix setup. Only change things"
	echo "# if you know exactly what you are doing!"
	echo "# by default, only DEPEND is inherited from the parent in"
	echo "# the chain. if you want more, make it a comma seperated"
	echo "# list - like this: DEPEND,RDEPEND,PDEPEN - which would the"
	echo "# all that is possible"
	echo "#"
	echo "PORTDIR=\"$(portageq envvar PORTDIR)\""
	echo "SYNC=\"$(portageq envvar SYNC || true)\""
	if test -z "${PORT_TMPDIR}"; then
		case "${CHILD_PROFILE}" in
		*winnt*)	echo "PORTAGE_TMPDIR=/var/tmp" ;;
		*)			echo "PORTAGE_TMPDIR=\"${CHILD_EPREFIX}/var/tmp\"" ;;
		esac
	else
		echo "PORTAGE_TMPDIR=\"${PORT_TMPDIR}\""
	fi
	echo "READONLY_EPREFIX=\"${PARENT_EPREFIX}:DEPEND\""

	if test "${DO_SOURCES}" == "yes"; then
		# don't fail if nothing found
		for f in /etc/portage/make.conf /etc/make.conf; do
			if [[ -r ${PARENT_EPREFIX}${f} ]]; then
				egrep "^source .*" "${PARENT_EPREFIX}${f}" 2>/dev/null || true
				break;
			fi
		done
	fi
) > "${CHILD_EPREFIX}"/etc/portage/make.conf
eend_exit $?

ebegin "creating profile/use.mask"
cat > "${CHILD_EPREFIX}"/etc/portage/profile/use.mask/prefix-chain-setup <<-'EOM'
	# masked in base profile, unmask here
	-prefix-chain
	EOM
eend_exit $?

ebegin "creating profile/use.force"
cat > "${CHILD_EPREFIX}"/etc/portage/profile/use.force/prefix-chain-setup <<-'EOM'
	# masked in base profile, force here
	prefix-chain
	EOM
eend_exit $?

#
# create the make.profile symlinks.
#
ebegin "creating make.profile"
(
	ln -s "${CHILD_PROFILE}" "${CHILD_EPREFIX}/etc/portage/make.profile"
)
eend_exit $?

#
# adjust permissions of generated files.
#
ebegin "adjusting permissions"
(
	chmod 644 "${CHILD_EPREFIX}"/etc/portage/make.conf
)
eend_exit $?

#
# now merge some basics.
#
ebegin "installing required basic packages"
(
	# this -pv is there to avoid the global update output, which is
	# there on the first emerge run. (thus, just cosmetics).
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -p1qO baselayout-prefix > /dev/null 2>&1

	set -e
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO \
		gentoo-functions baselayout-prefix gnuconfig prefix-chain-utils

	# merge with the parent's chost. this forces the use of the parent
	# compiler, which generally would be illegal - this is an exception.
	# This is required for example on winnt, because the wrapper has to
	# be able to use/resolve symlinks, etc. native winnt binaries miss that
	# ability, but interix binaries don't.
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" CHOST="${PARENT_CHOST}" emerge -1qO gcc-config

	# select the chain wrapper profile from gcc-config
	env -i "$(type -P bash)" "${CHILD_EPREFIX}"/usr/bin/gcc-config 1

	# do this _AFTER_ selecting the correct compiler!
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO libtool
)
eend_exit $?

#
# wow, all ok :)
#
ewarn
ewarn "all done. don't forget to tune ${CHILD_EPREFIX}/etc/portage/make.conf."
ewarn "to enter the new prefix, run \"${CHILD_EPREFIX}/startprefix\"."
ewarn
EOF
}
