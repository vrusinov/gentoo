# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

KEYWORDS="~amd64"
ROS_REPO_URI="https://github.com/ros-visualization/rqt_robot_plugins"
PYTHON_COMPAT=( python2_7 )
ROS_SUBDIR=${PN}

inherit ros-catkin

DESCRIPTION="Displays diagnostics_agg topics messages that are published by diagnostic_aggregator"
LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="
	dev-ros/diagnostic_msgs[${CATKIN_MESSAGES_PYTHON_USEDEP}]
	dev-ros/python_qt_binding[${PYTHON_USEDEP}]
	dev-python/rospkg[${PYTHON_USEDEP}]
	dev-ros/qt_gui[${PYTHON_USEDEP}]
	dev-ros/qt_gui_py_common[${PYTHON_USEDEP}]
	dev-ros/rospy[${PYTHON_USEDEP}]
	dev-ros/rqt_gui[${PYTHON_USEDEP}]
	dev-ros/rqt_gui_py[${PYTHON_USEDEP}]
	dev-ros/rqt_py_common[${PYTHON_USEDEP}]
	dev-ros/rqt_bag[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
