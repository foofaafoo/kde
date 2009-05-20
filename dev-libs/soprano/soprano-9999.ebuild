# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

JAVA_PKG_OPT_USE="java"
inherit base cmake-utils flag-o-matic subversion java-pkg-opt-2

DESCRIPTION="Library that provides a nice QT interface to RDF storage solutions"
HOMEPAGE="http://sourceforge.net/projects/soprano"
ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/kdesupport/${PN}"

LICENSE="LGPL-2"
KEYWORDS=""
SLOT="0"
# virtuoso disabled for now
IUSE="+clucene +dbus debug doc elibc_FreeBSD java +raptor +redland"

COMMON_DEPEND="
	x11-libs/qt-core:4
	clucene? ( dev-cpp/clucene )
	dbus? ( x11-libs/qt-dbus:4 )
	raptor? ( >=media-libs/raptor-1.4.16 )
	redland? (
		>=dev-libs/rasqal-0.9.15
		>=dev-libs/redland-1.0.6
	)
	java? ( >=virtual/jdk-1.6.0 )
	virtuoso? ( dev-db/libiodbc )
"
DEPEND="${COMMON_DEPEND}
	doc? ( app-doc/doxygen )
"
RDEPEND="${COMMON_DEPEND}
	virtuoso? ( dev-db/virtuoso )
"

CMAKE_IN_SOURCE_BUILD="1"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	echo
	ewarn "WARNING! This is an experimental ebuild of ${PN} SVN tree. Use at your own risk."
	ewarn "Do _NOT_ file bugs at bugs.gentoo.org because of this ebuild!"
	echo
	if ! use redland && ! use java && ! use virtuoso ; then
		ewarn "You explicitly disabled default soprano backend and haven't chosen other one."
		ewarn "Applications using soprano may need at least one backend functional."
		ewarn "If you experience any problems, enable any of those USE flags:"
		ewarn "redland, java, virtuoso"
	fi
}

src_prepare() {
	base_src_prepare
}

src_configure() {
	# Fix for missing pthread.h linking
	# NOTE: temporarely fix until a better cmake files patch will be provided.
	use elibc_FreeBSD && append-ldflags "-lpthread"

	mycmakeargs="${mycmakeargs}
		-DSOPRANO_BUILD_TESTS=OFF
		-DCMAKE_SKIP_RPATH=OFF"

	! use clucene && mycmakeargs="${mycmakeargs} -DSOPRANO_DISABLE_CLUCENE_INDEX=ON"
	! use dbus && mycmakeargs="${mycmakeargs} -DSOPRANO_DISABLE_DBUS=ON"
	! use raptor && mycmakeargs="${mycmakeargs} -DSOPRANO_DISABLE_RAPTOR_PARSER=ON"
	! use redland && mycmakeargs="${mycmakeargs} -DSOPRANO_DISABLE_REDLAND_BACKEND=ON"
	! use java && mycmakeargs="${mycmakeargs} -DSOPRANO_DISABLE_SESAME2_BACKEND=ON"
	! use virtuoso && mycmakeargs="${mycmakeargs} -DSOPRANO_DISABLE_VIRTUOSO_BACKEND=ON"
	use doc && mycmakeargs="${mycmakeargs} -DSOPRANO_BUILD_API_DOCS=ON"

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_test() {
	mycmakeargs="${mycmakeargs}
		-DSOPRANO_BUILD_TESTS=ON"
	cmake-utils_src_configure
	cmake-utils_src_compile
	ctest --extra-verbose || die "Tests failed."
}
