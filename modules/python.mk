################################################################################
# python modules
#
# TODO:
# * fix failing tests: test_asyncio test_asyncio test_socket
################################################################################

python_dist_url   := https://www.python.org/ftp/python/3.12.10/Python-3.12.10.tar.xz
python_dist_sum   := 520c30e3958d0be3c127e5dbb1c52bb3bfc404b5b3c7eb56525e25b9b59af9b21b53bee192f323f470e1df806f6cb2dd3411eb90cbc1c4b7d9b6b0777c29e644
python_dist_name  := $(subst P,p,$(notdir $(python_dist_url)))
python_vers       := $(patsubst python-%.tar.xz,%,$(python_dist_name))
_python_vers_toks := $(subst .,$(space),$(python_vers))
python_vers_maj   := $(word 1,$(_python_vers_toks))
python_vers_min   := $(word 2,$(_python_vers_toks))
python_brief      := Interactive high-level object-oriented language
python_home       := http://www.python.org/
define python_patches
#$(call patch,$(srcdir)/python,$(PATCHDIR)/python-3.10.4-000-ensurepip_force_modules_install.patch,-p1)
endef

define python_desc
Python, the high-level, interactive object oriented language, includes an
extensive class library with lots of goodies for network programming, system
administration, sounds and graphics.
endef

define fetch_python_dist
$(call download_csum,$(python_dist_url),\
                     $(python_dist_name),\
                     $(python_dist_sum))
endef
$(call gen_fetch_rules,python,python_dist_name,fetch_python_dist)

define xtract_python
$(call rmrf,$(srcdir)/python)
$(call untar,$(srcdir)/python,\
             $(FETCHDIR)/$(python_dist_name),\
             --strip-components=1)
$(python_patches)
endef
$(call gen_xtract_rules,python,xtract_python)

$(call gen_dir_rules,python)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define python_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/python/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define python_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define python_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define python_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(call slink,python$(python_vers_maj),$(strip $(3))$(strip $(2))/bin/python)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define python_uninstall_cmds
$(call rmf,$(strip $(3))$(strip $(2))/bin/python)
$(call rmf,$(strip $(3))$(strip $(2))/bin/python$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/pydoc$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/2to3*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/pip$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/idle$(python_vers_maj)*)
$(call rmrf,$(strip $(3))$(strip $(2))/include/python$(python_vers_maj)*)
$(call rmrf,$(strip $(3))$(strip $(2))/lib/python$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/libpython$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/pkgconfig/python-$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/pkgconfig/python$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man1/python$(python_vers_maj)*)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

python_check_env := PATH="$(stagedir)/bin:$(PATH)" \
                    LD_LIBRARY_PATH="$(stage_lib_path):$(build_lib_search_path)"

# $(1): targets base name / module name
#
# Testsuite is carried out by calling the <python>/Tools/scripts/run_tests.py
# script from the top-level build directory Makefile. It is called with make
# variable RUNSHARED as environment variable and given the EXTRATESTOPTS make
# variable content as arguments.
#
# To get help informations about available tests and options, set EXTRATESTOPTS
# like so:
#     EXTRATESTOPTS='--help'
#
# To run the test_ctypes test in verbose mode, set EXTRATESTOPTS like so:
#     EXTRATESTOPTS='--verbose3 test_ctypes'
#
# test_ctypes fails to find the system wide C library since the used gcc is
# built using an alternate prefix pointing to $(stagedir). Give the testsuite a
# way to find it by setting RUNSHARED make variable so that the run_tests.py
# script is executed with the right PATH and LD_LIBRARY_PATH environment
# variables (see python_check_env macro definition).
define python_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         test \
         RUNSHARED='$(python_check_env) HOME="$(builddir)/$(strip $(1))/.home"' \
         EXTRATESTOPTS='-x test_distutils'
endef

python_common_config_args := --enable-shared \
                             --enable-optimizations \
                             --with-computed-gotos \
                             --with-lto \
                             --enable-ipv6 \
                             --enable-loadable-sqlite-extensions \
                             --with-system-expat \
                             --with-system-ffi \
                             --with-system-libmpdec \
                             --with-readline \
                             --with-openssl='$(stagedir)' \
                             --with-ensurepip=install

################################################################################
# Staging definitions
################################################################################

# Remove -flto from build flags since preventing python configure script to
# properly detect float word ordering. We pass the configure script the
# '--with-lto' option instead.
# Build does not support building in PIE mode.
python_stage_config_args := $(python_common_config_args) \
                            $(call stage_config_flags,$(lto_flags))

$(call gen_deps,stage-python,stage-readline \
                             stage-util-linux \
                             stage-ncurses \
                             stage-gdbm \
                             stage-openssl \
                             stage-pkg-config \
                             stage-libffi \
                             stage-expat \
                             stage-libmpdec \
                             stage-sqlite \
                             stage-bzip2 \
                             stage-xz-utils)
$(call gen_check_deps,stage-python,stage-gdb)

config_stage-python    = $(call python_config_cmds,stage-python,\
                                                   $(stagedir),\
                                                   $(python_stage_config_args))
build_stage-python     = $(call python_build_cmds,stage-python)
clean_stage-python     = $(call python_clean_cmds,stage-python)
install_stage-python   = $(call python_install_cmds,stage-python,$(stagedir))
uninstall_stage-python = $(call python_uninstall_cmds,stage-python,$(stagedir))
check_stage-python     = $(call python_check_cmds,stage-python)

$(call gen_config_rules_with_dep,stage-python,python,config_stage-python)
$(call gen_clobber_rules,stage-python)
$(call gen_build_rules,stage-python,build_stage-python)
$(call gen_clean_rules,stage-python,clean_stage-python)
$(call gen_install_rules,stage-python,install_stage-python)
$(call gen_uninstall_rules,stage-python,uninstall_stage-python)
$(call gen_check_rules,stage-python,check_stage-python)
$(call gen_dir_rules,stage-python)

################################################################################
# Final definitions
################################################################################

python_final_config_args := $(python_common_config_args) \
                            $(call final_config_flags,$(lto_flags)) \
                            LD_LIBRARY_PATH="$(stage_lib_path)"

$(call gen_deps,final-python,stage-readline \
                             stage-util-linux \
                             stage-ncurses \
                             stage-gdbm \
                             stage-openssl \
                             stage-pkg-config \
                             stage-libffi \
                             stage-expat \
                             stage-libmpdec \
                             stage-sqlite \
                             stage-bzip2 \
                             stage-xz-utils \
                             stage-python \
                             stage-tcl)
$(call gen_check_deps,final-python,stage-gdb)

config_final-python    = $(call python_config_cmds,final-python,\
                                                   $(PREFIX),\
                                                   $(python_final_config_args))
build_final-python     = $(call python_build_cmds,final-python)
clean_final-python     = $(call python_clean_cmds,final-python)

final-python_shebang_fixups = \
	$(addprefix $(python_site_path_comp)/,\
	            ../smtpd.py \
	            pip/_vendor/distro/distro.py \
	            ../cgi.py \
	            ../turtledemo/yinyang.py \
	            ../turtledemo/forest.py \
	            ../turtledemo/peace.py \
	            ../turtledemo/__main__.py \
	            ../turtledemo/bytedesign.py \
	            ../turtledemo/penrose.py \
	            ../turtledemo/tree.py \
	            ../turtledemo/fractalcurves.py \
	            ../turtledemo/paint.py \
	            ../turtledemo/sorting_animate.py \
	            ../turtledemo/planet_and_moon.py \
	            ../turtledemo/lindenmayer.py \
	            ../turtledemo/minimal_hanoi.py \
	            ../turtledemo/clock.py \
	            ../smtplib.py \
	            ../tabnanny.py \
	            ../idlelib/idle_test/example_noext \
	            ../idlelib/pyshell.py \
	            ../cProfile.py \
	            ../quopri.py \
	            ../pdb.py \
	            ../profile.py \
	            ../lib2to3/pgen2/token.py \
	            ../lib2to3/tests/pytree_idempotency.py \
	            ../lib2to3/tests/data/false_encoding.py \
	            ../tarfile.py \
	            ../platform.py \
	            ../test/bisect_cmd.py \
	            ../test/curses_tests.py \
	            ../test/regrtest.py \
	            ../test/re_tests.py \
	            ../timeit.py \
	            ../pydoc.py \
	            ../trace.py \
	            ../uu.py \
	            ../webbrowser.py \
	            ../encodings/rot_13.py \
	            ../base64.py)

define install_final-python
$(call python_install_cmds,final-python,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-python_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

uninstall_final-python = $(call python_uninstall_cmds,final-python,\
                                                      $(PREFIX),\
                                                      $(finaldir))
check_final-python     = $(call python_check_cmds,final-python)

$(call gen_config_rules_with_dep,final-python,python,config_final-python)
$(call gen_clobber_rules,final-python)
$(call gen_build_rules,final-python,build_final-python)
$(call gen_clean_rules,final-python,clean_final-python)
$(call gen_install_rules,final-python,install_final-python)
$(call gen_uninstall_rules,final-python,uninstall_final-python)
$(call gen_check_rules,final-python,check_final-python)
$(call gen_dir_rules,final-python)
