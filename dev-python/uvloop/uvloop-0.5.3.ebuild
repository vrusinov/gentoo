# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 )
inherit distutils-r1

DESCRIPTION="Ultra-fast implementation of asyncio event loop on top of libuv."
HOMEPAGE="https://github.com/magicstack/uvloop"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="MIT"
SLOT="0"
IUSE="doc examples test"

RDEPEND=">=dev-libs/libuv-1.9.0:="
DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? (
		>=dev-python/alabaster-0.6.2[${PYTHON_USEDEP}]
		>=dev-python/cython-0.24.1[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
	)
	test? (
		>=dev-python/cython-0.24.1[${PYTHON_USEDEP}]
	)
"

python_prepare_all() {
	cat <<EOF >> setup.cfg
[build_ext]
use-system-libuv=1
EOF

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake docs
}

python_test() {
	esetup.py test
}

python_install_all() {
	use examples && dodoc -r examples
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
