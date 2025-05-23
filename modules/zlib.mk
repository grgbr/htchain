################################################################################
# zlib modules
#
# Note: unit testing segfaults when built with assembly support using x86
#       gvmat64.S
################################################################################

zlib_dist_url  := https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.xz
zlib_dist_sum  := 1e8e70b362d64a233591906a1f50b59001db04ca14aaffad522198b04680be501736e7d536b4191e2f99767e7001ca486cd802362cca2be05d5d409b83ea732d
zlib_dist_name := $(notdir $(zlib_dist_url))
zlib_vers      := $(patsubst zlib-%.tar.xz,%,$(zlib_dist_name))
zlib_brief     := ZLib compression library
zlib_home      := http://zlib.net/
define zlib_patches
# $(call patch,$(srcdir)/zlib,$(PATCHDIR)/zlib-1.2.13-000-fix_config_gcc.patch,-p1)
# $(call patch,$(srcdir)/zlib,$(PATCHDIR)/zlib-1.2.13-001-fix_shared_test_build_flags.patch,-p1)
endef

define zlib_desc
Zlib is a library implementing the deflate compression method found in ``gzip``
and ``PKZIP``.
endef

define fetch_zlib_dist
$(call download_csum,$(zlib_dist_url),\
                     $(zlib_dist_name),\
                     $(zlib_dist_sum))
endef
$(call gen_fetch_rules,zlib,zlib_dist_name,fetch_zlib_dist)

define xtract_zlib
$(call rmrf,$(srcdir)/zlib)
$(call untar,$(srcdir)/zlib,$(FETCHDIR)/$(zlib_dist_name),--strip-components=1)
$(zlib_patches)
endef
$(call gen_xtract_rules,zlib,xtract_zlib)

$(call gen_dir_rules,zlib)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure environment variables
# $(4): configure arguments
define zlib_config_cmds
cd $(builddir)/$(strip $(1)) && \
env $(3) $(srcdir)/zlib/configure --prefix="$(strip $(2))" $(4) $(verbose)
endef

# $(1): targets base name / module name
# $(2): shared objects compile flags
# $(3): test objects link flags
# $(4): optional additional make command line arguments
define zlib_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         SFLAGS='$(2)' \
         TEST_LDFLAGS='$(3)' \
         $(4)
endef

# $(1): targets base name / module name
define zlib_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define zlib_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))')
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define zlib_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(strip $(3)),DESTDIR='$(strip $(3))')
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): shared objects compile flags
# $(3): test objects link flags
# $(4): optional additional make command line arguments
define zlib_check_cmds
+env LD_LIBRARY_PATH="$(builddir)/$(strip $(1))/lib" \
$(MAKE) --directory $(builddir)/$(strip $(1)) \
         test \
         SFLAGS='$(2)' \
         TEST_LDFLAGS='$(3)' \
         $(4)
endef

################################################################################
# Staging definitions
################################################################################

zlib_stage_cflags      := $(call xclude_flags,$(o_flags),$(stage_cflags)) -O3 \
                          -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN
zlib_stage_libcflags   := $(call xclude_flags,$(pie_flags),\
                                              $(zlib_stage_cflags)) -fPIC -DPIC
zlib_stage_testflags   := $(call xclude_flags,$(o_flags) $(rpath_flags),\
                                              $(stage_ldflags)) -O3
zlib_stage_ldflags     := $(call xclude_flags,$(pie_flags) $(rpath_flags),\
                                              $(stage_ldflags))

ifneq ($(mach_is_64bits),)
zlib_stage_config_args := --64
endif

zlib_stage_config_env  := AR='$(stage_ar)' \
                          NM='$(stage_nm)' \
                          RANLIB='$(stage_ranlib)' \
                          CC='$(stage_cc)' \
                          CXX='$(stage_cxx)' \
                          CFLAGS='$(zlib_stage_cflags)' \
                          LDFLAGS='$(zlib_stage_ldflags)'

$(call gen_deps,stage-zlib,stage-gcc)

config_stage-zlib       = $(call zlib_config_cmds,stage-zlib,\
                                                  $(stagedir),\
                                                  $(zlib_stage_config_env),\
                                                  $(zlib_stage_config_args))
build_stage-zlib        = $(call zlib_build_cmds,stage-zlib,\
                                                 $(zlib_stage_libcflags),\
                                                 $(zlib_stage_testflags))
clean_stage-zlib        = $(call zlib_clean_cmds,stage-zlib)
install_stage-zlib      = $(call zlib_install_cmds,stage-zlib)
uninstall_stage-zlib    = $(call zlib_uninstall_cmds,stage-zlib,$(stagedir))
check_stage-zlib        = $(call zlib_check_cmds,stage-zlib,\
                                                 $(zlib_stage_libcflags),\
                                                 $(zlib_stage_testflags))

$(call gen_config_rules_with_dep,stage-zlib,zlib,config_stage-zlib)
$(call gen_clobber_rules,stage-zlib)
$(call gen_build_rules,stage-zlib,build_stage-zlib)
$(call gen_clean_rules,stage-zlib,clean_stage-zlib)
$(call gen_install_rules,stage-zlib,install_stage-zlib)
$(call gen_uninstall_rules,stage-zlib,uninstall_stage-zlib)
$(call gen_check_rules,stage-zlib,check_stage-zlib)
$(call gen_dir_rules,stage-zlib)

################################################################################
# Final definitions
################################################################################

zlib_final_cflags      := $(call xclude_flags,$(o_flags),$(final_cflags)) -O3 \
                          -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN
zlib_final_libcflags   := $(call xclude_flags,$(pie_flags),\
                                              $(zlib_final_cflags)) -fPIC -DPIC
zlib_final_testflags   := $(call xclude_flags,$(o_flags) $(rpath_flags),\
                                              $(final_ldflags)) -O3
zlib_final_ldflags     := $(call xclude_flags,$(pie_flags) $(rpath_flags),\
                                              $(final_ldflags))

ifneq ($(mach_is_64bits),)
zlib_final_config_args := --64
endif

zlib_final_config_env  := AR='$(stage_ar)' \
                          NM='$(stage_nm)' \
                          RANLIB='$(stage_ranlib)' \
                          CC='$(stage_cc)' \
                          CXX='$(stage_cxx)' \
                          CFLAGS='$(zlib_final_cflags)' \
                          LDFLAGS='$(zlib_final_ldflags)'

$(call gen_deps,final-zlib,stage-gcc)

config_final-zlib       = $(call zlib_config_cmds,final-zlib,\
                                                  $(PREFIX),\
                                                  $(zlib_final_config_env),\
                                                  $(zlib_final_config_args))
build_final-zlib        = $(call zlib_build_cmds,final-zlib,\
                                                 $(zlib_final_libcflags),\
                                                 $(zlib_final_testflags))
clean_final-zlib        = $(call zlib_clean_cmds,final-zlib)
install_final-zlib      = $(call zlib_install_cmds,final-zlib,$(finaldir))
uninstall_final-zlib    = $(call zlib_uninstall_cmds,final-zlib,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-zlib        = $(call zlib_check_cmds,final-zlib,\
                                                 $(zlib_final_libcflags),\
                                                 $(zlib_final_testflags))

$(call gen_config_rules_with_dep,final-zlib,zlib,config_final-zlib)
$(call gen_clobber_rules,final-zlib)
$(call gen_build_rules,final-zlib,build_final-zlib)
$(call gen_clean_rules,final-zlib,clean_final-zlib)
$(call gen_install_rules,final-zlib,install_final-zlib)
$(call gen_uninstall_rules,final-zlib,uninstall_final-zlib)
$(call gen_check_rules,final-zlib,check_final-zlib)
$(call gen_dir_rules,final-zlib)
