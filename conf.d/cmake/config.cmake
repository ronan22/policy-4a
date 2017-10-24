###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# author: Fulup Ar Foll <fulup@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################

# Project Info
# ------------------
set(PROJECT_NAME afb-controller)
set(PROJECT_VERSION "1.0")
set(PROJECT_PRETTY_NAME "Controller Binding for AGL Application Framework")
set(PROJECT_DESCRIPTION "Create controls that could be mapped to LUA functions, callback or API/VERB methods.")
set(PROJECT_URL "https://github.com/iotbzh/controller-binding")
set(PROJECT_ICON "icon.png")
set(PROJECT_AUTHOR "Fulup Ar Foll")
set(PROJECT_AUTHOR_MAIL "fulup@iot.bzh")
set(PROJECT_LICENSE "APL2.0")
set(PROJECT_LANGUAGES,"C")

# Where are stored default templates files from submodule or subtree app-templates in your project tree
# relative to the root project directory
set(PROJECT_APP_TEMPLATES_DIR "conf.d/app-templates")

# Where are stored your external libraries for your project. This is 3rd party library that you don't maintain
# but used and must be built and linked.
# set(PROJECT_LIBDIR "libs")

# Where are stored data for your application. Pictures, static resources must be placed in that folder.
# set(PROJECT_RESOURCES "data")

# Which directories inspect to find CMakeLists.txt target files
# set(PROJECT_SRC_DIR_PATTERN "*")

# Compilation Mode (DEBUG, RELEASE)
# ----------------------------------
set(CMAKE_BUILD_TYPE "DEBUG")


# Kernel selection if needed. You can choose between a
# mandatory version to impose a minimal version.
# Or check Kernel minimal version and just print a Warning
# about missing features and define a preprocessor variable
# to be used as preprocessor condition in code to disable
# incompatibles features. Preprocessor define is named
# KERNEL_MINIMAL_VERSION_OK.
#
# NOTE*** FOR NOW IT CHECKS KERNEL Yocto environment and
# Yocto SDK Kernel version.
# -----------------------------------------------
#set (kernel_mandatory_version 4.8)
#set (kernel_minimal_version 4.8)

# Compiler selection if needed. Impose a minimal version.
# -----------------------------------------------
set (gcc_minimal_version 4.9)

# PKG_CONFIG required packages
# -----------------------------
set (PKG_REQUIRED_LIST
	json-c
	libsystemd>=222
	afb-daemon
	libmicrohttpd>=0.9.55
        libafbwsc
)

# Customize link option
# -----------------------------
#list(APPEND link_libraries -an-option)

# Prefix path where will be installed the files
# Default: /usr/local (need root permission to write in)
# ------------------------------------------------------
set(CMAKE_INSTALL_PREFIX $ENV{HOME}/opt)

# When Present LUA is used by the controller
# ---------------------------------------------------------------
set(CONTROL_SUPPORT_LUA 1 CACHE BOOL "Active or not LUA Support")

# Controller project needed variables.
# Compilation options specific to that target set
# in the CMakeLists.txt of that target to correctly
# expand variables.
# ----------------------------------------------------
set (CTL_PLUGIN_PRE "ctl-" CACHE STRING "Prefix for Controller share plugin")
set (CTL_PLUGIN_EXT ".ctlso" CACHE STRING "Postfix for Controller share plugin")

# Compilation options definition
# Use CMake generator expressions to specify only for a specific language
# Values are prefilled with default options that is currently used.
# Either separate options with ";", or each options must be quoted separately
# DO NOT PUT ALL OPTION QUOTED AT ONCE , COMPILATION COULD FAILED !
# ----------------------------------------------------------------------------
set(COMPILE_OPTIONS
-Wall
-Wextra
-Wconversion
-Wno-unused-parameter
-Wno-sign-compare
-Wno-sign-conversion
-Werror=maybe-uninitialized
-Werror=implicit-function-declaration
-ffunction-sections
-fdata-sections
-fPIC
# Personal compilation options
-DCONTROL_MAXPATH_LEN=255
-DCONTROL_ONLOAD_PROFILE="onload-default"
-DCONTROL_DOSCRIPT_PRE="doscript"
-DCONTROL_CONFIG_PRE="onload"
-DCONTROL_CONFIG_POST="control"
-DCONTROL_CONFIG_PATH="${CMAKE_SOURCE_DIR}/conf.d/project:${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}"
-DCTL_PLUGIN_MAGIC=2468013579
-DCONTROL_PLUGIN_PATH="${CMAKE_BINARY_DIR}:${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/lib/controller-plugins:/usr/lib/afb/controller-plugins/ctlplug"
 CACHE STRING "Compilation flags")


# Print a helper message when every thing is finished
# ----------------------------------------------------
if(IS_DIRECTORY $ENV{HOME}/opt/afb-monitoring)
set(MONITORING_ALIAS "--alias=/monitoring:$ENV{HOME}/opt/afb-monitoring")
endif()
set(CLOSING_MESSAGE "Debug: afb-daemon --name=afb-aaaa-pol4a --port=1234 --cntxtimeout=1 ${MONITORING_ALIAS} --ldpaths=package/lib:../../alsa-4a/build/package/lib:../../hal-sample-4a/build/package/lib --workdir=. --roothttp=../htdocs --tracereq=common --token= --verbose ")
set(PACKAGE_MESSAGE "Install widget file using in the target : afm-util install ${PROJECT_NAME}.wgt")

# (BUG!!!) as PKG_CONFIG_PATH does not work [should be an env variable]
# ---------------------------------------------------------------------
set(CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX}/lib64/pkgconfig ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
set(LD_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/lib64 ${CMAKE_INSTALL_PREFIX}/lib)

# Optional location for config.xml.in
# -----------------------------------
set(WIDGET_ICON conf.d/wgt/${PROJECT_ICON} CACHE PATH "Path to the widget icon")
set(WIDGET_CONFIG_TEMPLATE ${CMAKE_CURRENT_SOURCE_DIR}/conf.d/wgt/config.xml.in CACHE PATH "Path to widget config file template (config.xml.in)")

# Mandatory widget Mimetype specification of the main unit
# --------------------------------------------------------------------------
# Choose between :
#- text/html : HTML application,
#	content.src designates the home page of the application
#
#- application/vnd.agl.native : AGL compatible native,
#	content.src designates the relative path of the binary.
#
# - application/vnd.agl.service: AGL service, content.src is not used.
#
#- ***application/x-executable***: Native application,
#	content.src designates the relative path of the binary.
#	For such application, only security setup is made.
#
set(WIDGET_TYPE application/vnd.agl.service)

# Mandatory Widget entry point file of the main unit
# --------------------------------------------------------------
# This is the file that will be executed, loaded,
# at launch time by the application framework.
#
set(WIDGET_ENTRY_POINT lib/afb-control-afb.so)

# Optional dependencies order
# ---------------------------
#set(EXTRA_DEPENDENCIES_ORDER)

# Optional Extra global include path
# -----------------------------------
#set(EXTRA_INCLUDE_DIRS)

# Optional extra libraries
# -------------------------
#set(EXTRA_LINK_LIBRARIES)

# Optional force binding Linking flag
# ------------------------------------
# set(BINDINGS_LINK_FLAG LinkOptions )

# Optional force package prefix generation, like widget
# -----------------------------------------------------
# set(PKG_PREFIX DestinationPath)

# Optional Application Framework security token
# and port use for remote debugging.
#------------------------------------------------------------
#set(AFB_TOKEN   ""      CACHE PATH "Default AFB_TOKEN")
#set(AFB_REMPORT "1234" CACHE PATH "Default AFB_TOKEN")

# Optional schema validator about now only XML, LUA and JSON
# are supported
#------------------------------------------------------------
#set(LUA_CHECKER "luac -o /dev/null" CACHE STRING "LUA compiler")
#set(XML_CHECKER "xmllint" CACHE STRING "XML linter")
#set(JSON_CHECKER "json_verify" CACHE STRING "JSON linter")

# This include is mandatory and MUST happens at the end
# of this file, else you expose you to unexpected behavior
# -----------------------------------------------------------
include(${PROJECT_APP_TEMPLATES_DIR}/cmake/common.cmake)
