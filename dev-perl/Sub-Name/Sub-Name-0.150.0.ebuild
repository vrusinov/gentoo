# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DIST_AUTHOR=ETHER
DIST_VERSION=0.15
inherit perl-module

DESCRIPTION="(Re)name a sub"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~s390 ~sh ~x86 ~ppc-aix ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test suggested"

RDEPEND="
	>=virtual/perl-Exporter-5.570.0
	virtual/perl-XSLoader
"
DEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		suggested? (
			dev-perl/Devel-CheckBin
		)
		virtual/perl-File-Spec
		virtual/perl-Module-Metadata
		>=virtual/perl-Test-Simple-0.880.0
	)
"
