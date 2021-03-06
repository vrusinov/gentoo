# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PLOCALES="cs de fr ja pl ru sl uk zh_CN zh_TW"

inherit eutils l10n qmake-utils toolchain-funcs virtualx xdg

DESCRIPTION="Lightweight IDE for C++/QML development centering around Qt"
HOMEPAGE="http://doc.qt.io/qtcreator/"
LICENSE="GPL-3"
SLOT="0"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI=(
		"git://code.qt.io/${PN}/${PN}.git"
		"https://code.qt.io/git/${PN}/${PN}.git"
	)
else
	MY_PV=${PV/_/-}
	MY_P=${PN}-opensource-src-${MY_PV}
	[[ ${MY_PV} == ${PV} ]] && MY_REL=official || MY_REL=development
	SRC_URI="http://download.qt.io/${MY_REL}_releases/${PN/-}/${PV%.*}/${MY_PV}/${MY_P}.tar.xz"
	KEYWORDS="~amd64 ~arm ~x86"
	S=${WORKDIR}/${MY_P}
fi

# TODO: unbundle sqlite

QTC_PLUGINS=('android:android|qmakeandroidsupport' autotools:autotoolsprojectmanager baremetal bazaar
	clangcodemodel clangstaticanalyzer clearcase cmake:cmakeprojectmanager cvs git glsl:glsleditor
	ios mercurial modeling:modeleditor nim perforce python:pythoneditor qbs:qbsprojectmanager qnx
	scxml:scxmleditor subversion valgrind winrt)
IUSE="doc systemd test +webengine ${QTC_PLUGINS[@]%:*}"

# minimum Qt version required
QT_PV="5.6.0:5"

RDEPEND="
	=dev-libs/botan-1.10*[-bindist,threads]
	>=dev-qt/designer-${QT_PV}
	>=dev-qt/qtconcurrent-${QT_PV}
	>=dev-qt/qtcore-${QT_PV}
	>=dev-qt/qtdeclarative-${QT_PV}[widgets]
	>=dev-qt/qtgui-${QT_PV}
	>=dev-qt/qthelp-${QT_PV}
	>=dev-qt/qtnetwork-${QT_PV}[ssl]
	>=dev-qt/qtprintsupport-${QT_PV}
	>=dev-qt/qtquickcontrols-${QT_PV}
	>=dev-qt/qtscript-${QT_PV}
	>=dev-qt/qtsql-${QT_PV}[sqlite]
	>=dev-qt/qtsvg-${QT_PV}
	>=dev-qt/qtwidgets-${QT_PV}
	>=dev-qt/qtx11extras-${QT_PV}
	>=dev-qt/qtxml-${QT_PV}
	sys-devel/gdb[client,python]
	clangcodemodel? ( >=sys-devel/clang-3.9:= )
	qbs? ( =dev-util/qbs-1.7* )
	systemd? ( sys-apps/systemd:= )
	webengine? ( >=dev-qt/qtwebengine-${QT_PV}[widgets] )
"
DEPEND="${RDEPEND}
	>=dev-qt/linguist-tools-${QT_PV}
	virtual/pkgconfig
	doc? ( >=dev-qt/qdoc-${QT_PV} )
	test? (
		>=dev-qt/qtdeclarative-${QT_PV}[localstorage,xml]
		>=dev-qt/qtquickcontrols2-${QT_PV}
		>=dev-qt/qttest-${QT_PV}
	)
"
# qt translations must also be installed or qt-creator translations won't be loaded
for x in ${PLOCALES}; do
	RDEPEND+=" linguas_${x}? ( >=dev-qt/qttranslations-${QT_PV} )"
done
unset x

PDEPEND="
	autotools? ( sys-devel/autoconf )
	bazaar? ( dev-vcs/bzr )
	clangstaticanalyzer? ( >=sys-devel/clang-3.9 )
	cmake? ( dev-util/cmake )
	cvs? ( dev-vcs/cvs )
	git? ( dev-vcs/git )
	mercurial? ( dev-vcs/mercurial )
	subversion? ( dev-vcs/subversion )
	valgrind? ( dev-util/valgrind )
"

src_unpack() {
	if tc-is-gcc; then
		if [[ $(gcc-major-version) -lt 4 ]] || \
		   [[ $(gcc-major-version) -eq 4 && $(gcc-minor-version) -lt 8 ]]; then
			eerror "GCC version 4.8 or later is required to build Qt Creator ${PV}"
			die "GCC >= 4.8 required"
		fi
	fi

	if [[ ${PV} == *9999 ]]; then
		git-r3_src_unpack
	else
		default
	fi
}

src_prepare() {
	default

	# disable unwanted plugins
	for plugin in "${QTC_PLUGINS[@]#[+-]}"; do
		if ! use ${plugin%:*}; then
			einfo "Disabling ${plugin%:*} plugin"
			sed -i -re "/(^\s+|SUBDIRS\s*\+=\s*)(${plugin#*:})\>/d" \
				src/plugins/plugins.pro || die "failed to disable ${plugin%:*} plugin"
		fi
	done

	# avoid building unused support libraries
	if ! use clangcodemodel; then
		sed -i -e '/clangbackendipc/d' src/libs/libs.pro || die
	fi
	if ! use glsl; then
		sed -i -e '/glsl/d' src/libs/libs.pro || die
	fi
	if ! use modeling; then
		sed -i -e '/modelinglib/d' src/libs/libs.pro || die
	fi

	# automagic dep on qtwebengine
	if ! use webengine; then
		sed -i -e 's/isEmpty(QT\.webenginewidgets\.name)/true/' src/plugins/help/help.pro || die
	fi

	# disable broken or unreliable tests
	sed -i -e '/SUBDIRS/ s/\<dumpers\>//' tests/auto/debugger/debugger.pro || die
	sed -i -e '/CONFIG -=/ s/$/ testcase/' tests/auto/extensionsystem/pluginmanager/correctplugins1/plugin?/plugin?.pro || die
	sed -i -e '/\(^char qmlString\|states\.qml$\)/ i return;' tests/auto/qml/qmldesigner/coretests/tst_testcore.cpp || die
	sed -i -e 's/\<timeline\(items\|notes\|selection\)renderpass\>//' tests/auto/timeline/timeline.pro || die
	sed -i -e 's/\<memcheck\>//' tests/auto/valgrind/valgrind.pro || die

	# fix translations
	sed -i -e "/^LANGUAGES =/ s:=.*:= $(l10n_get_locales):" \
		share/qtcreator/translations/translations.pro || die

	# remove bundled qbs
	rm -rf src/shared/qbs || die
}

src_configure() {
	eqmake5 IDE_LIBRARY_BASENAME="$(get_libdir)" \
		IDE_PACKAGE_MODE=1 \
		$(use clangcodemodel && echo LLVM_INSTALL_DIR="${EPREFIX}/usr") \
		$(use qbs && echo QBS_INSTALL_DIR="${EPREFIX}/usr") \
		CONFIG+=qbs_disable_rpath \
		CONFIG+=qbs_enable_project_file_updates \
		$(use systemd && echo CONFIG+=journald) \
		$(use test && echo BUILD_TESTS=1) \
		USE_SYSTEM_BOTAN=1
}

src_test() {
	cd tests/auto && virtx default
}

src_install() {
	emake INSTALL_ROOT="${ED}usr" install

	dodoc dist/{changes-*,known-issues}

	# install documentation
	if use doc; then
		emake docs
		# don't use ${PF} or the doc will not be found
		insinto /usr/share/doc/qtcreator
		doins share/doc/qtcreator/qtcreator{,-dev}.qch
		docompress -x /usr/share/doc/qtcreator/qtcreator{,-dev}.qch
	fi

	# create a desktop file
	make_desktop_entry qtcreator 'Qt Creator' QtProject-qtcreator 'Development;IDE;Qt;' \
		'MimeType=text/x-c++src;text/x-c++hdr;text/x-xsrc;application/x-designer;application/vnd.qt.qmakeprofile;application/vnd.qt.xml.resource;text/x-qml;text/x-qt.qml;text/x-qt.qbs;'
}
