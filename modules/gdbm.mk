################################################################################
# gdbm modules
################################################################################

gdbm_dist_url  := https://ftp.gnu.org/gnu/gdbm/gdbm-1.25.tar.gz
gdbm_dist_sum  := 1785598665d7323eed052a55708903c6abaeafcfb66a9ceb69293f57c3fdbf49cd8a821ef23715a40bf7030d0067d1340d12279ed07afe040f912e53078e47f5
gdbm_dist_name := $(notdir $(gdbm_dist_url))
gdbm_vers      := $(patsubst gdbm-%.tar.gz,%,$(gdbm_dist_name))
gdbm_brief     := GNU dbm database routines
gdbm_home      := https://gnu.org/software/gdbm

define gdbm_desc
GNU dbm is a library of database functions that use extendible hashing and works
similarly to the standard UNIX *dbm* functions.

The basic use of gdbm is to store key/data pairs in a data file, thus providing
a persistent version of the dictionary Abstract Data Type (hash to perl_
programmers).
endef

define fetch_gdbm_dist
$(call download_csum,$(gdbm_dist_url),\
                     $(gdbm_dist_name),\
                     $(gdbm_dist_sum))
endef
$(call gen_fetch_rules,gdbm,gdbm_dist_name,fetch_gdbm_dist)

define xtract_gdbm
$(call rmrf,$(srcdir)/gdbm)
$(call untar,$(srcdir)/gdbm,\
             $(FETCHDIR)/$(gdbm_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,gdbm,xtract_gdbm)

$(call gen_dir_rules,gdbm)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gdbm_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/gdbm/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
#
# The final symlink creation is a dirty hack to workaround the dumb final-tcl
# configure script expecting to find libgdbm.so and gdbm.h located into the same
# directory... See modules/tcl.mk for more infos.
define gdbm_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define gdbm_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gdbm_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gdbm_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define gdbm_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check $(2)
endef

gdbm_common_config_args := --enable-silent-rules \
                           --enable-libgdbm-compat \
                           --enable-shared \
                           --enable-static \
                           --with-readline \
                           --disable-debug

################################################################################
# Staging definitions
################################################################################

gdbm_stage_config_args := $(gdbm_common_config_args) \
                          --disable-nls \
                          --with-sysroot='$(stagedir)' \
                          MAKEINFO=true \
                          $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-gdbm,stage-gcc stage-readline)

config_stage-gdbm    = $(call gdbm_config_cmds,stage-gdbm,\
                                               $(stagedir),\
                                               $(gdbm_stage_config_args))
build_stage-gdbm     = $(call gdbm_build_cmds,stage-gdbm)
clean_stage-gdbm     = $(call gdbm_clean_cmds,stage-gdbm)
install_stage-gdbm   = $(call gdbm_install_cmds,stage-gdbm,$(stagedir))
uninstall_stage-gdbm = $(call gdbm_uninstall_cmds,stage-gdbm,$(stagedir))
check_stage-gdbm     = $(call gdbm_check_cmds,stage-gdbm)

$(call gen_config_rules_with_dep,stage-gdbm,gdbm,config_stage-gdbm)
$(call gen_clobber_rules,stage-gdbm)
$(call gen_build_rules,stage-gdbm,build_stage-gdbm)
$(call gen_clean_rules,stage-gdbm,clean_stage-gdbm)
$(call gen_install_rules,stage-gdbm,install_stage-gdbm)
$(call gen_uninstall_rules,stage-gdbm,uninstall_stage-gdbm)
$(call gen_check_rules,stage-gdbm,check_stage-gdbm)
$(call gen_dir_rules,stage-gdbm)

################################################################################
# Final definitions
################################################################################

gdbm_final_config_args := $(gdbm_common_config_args) \
                          --enable-nls \
                          --with-sysroot='$(finaldir)$(PREFIX)' \
                          $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-gdbm,stage-readline stage-gettext stage-texinfo)

config_final-gdbm    = $(call gdbm_config_cmds,final-gdbm,\
                                               $(PREFIX),\
                                               $(gdbm_final_config_args))
build_final-gdbm     = $(call gdbm_build_cmds,final-gdbm)
clean_final-gdbm     = $(call gdbm_clean_cmds,final-gdbm)
install_final-gdbm   = $(call gdbm_install_cmds,final-gdbm,\
                                                $(PREFIX),\
                                                $(finaldir))
uninstall_final-gdbm = $(call gdbm_uninstall_cmds,final-gdbm,\
                                                  $(PREFIX),\
                                                  $(finaldir))
check_final-gdbm     = $(call gdbm_check_cmds,final-gdbm,\
                              LD_LIBRARY_PATH='$(stage_lib_path)')

$(call gen_config_rules_with_dep,final-gdbm,gdbm,config_final-gdbm)
$(call gen_clobber_rules,final-gdbm)
$(call gen_build_rules,final-gdbm,build_final-gdbm)
$(call gen_clean_rules,final-gdbm,clean_final-gdbm)
$(call gen_install_rules,final-gdbm,install_final-gdbm)
$(call gen_uninstall_rules,final-gdbm,uninstall_final-gdbm)
$(call gen_check_rules,final-gdbm,check_final-gdbm)
$(call gen_dir_rules,final-gdbm)
