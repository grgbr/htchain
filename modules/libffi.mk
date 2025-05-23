################################################################################
# libffi modules
################################################################################

libffi_dist_url  := https://github.com/libffi/libffi/releases/download/v3.4.5/libffi-3.4.5.tar.gz
libffi_dist_sum  := 4834735e533be450c541a75555252759c8e00694539d040f248a85dbbf58329938db6ae3e2ce74c3e4e3c82e97eccedee1ea0caff1afd8dacd8976a1aa08702a
libffi_dist_name := $(notdir $(libffi_dist_url))
libffi_vers      := $(patsubst libffi-%.tar.gz,%,$(libffi_dist_name))
libffi_brief     := Foreign Function Interface library
libffi_home      := https://sourceware.org/libffi/

define libffi_desc
A foreign function interface is the popular name for the interface that allows
code written in one language to call code written in another language.
endef

define fetch_libffi_dist
$(call download_csum,$(libffi_dist_url),\
                     $(libffi_dist_name),\
                     $(libffi_dist_sum))
endef
$(call gen_fetch_rules,libffi,libffi_dist_name,fetch_libffi_dist)

define xtract_libffi
$(call rmrf,$(srcdir)/libffi)
$(call untar,$(srcdir)/libffi,\
             $(FETCHDIR)/$(libffi_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libffi,xtract_libffi)

$(call gen_dir_rules,libffi)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libffi_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libffi/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libffi_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define libffi_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libffi_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libffi_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# PATH required to find dejaGNU `runtest' tool.
define libffi_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH="$(stagedir)/bin:$(PATH)"
endef

libffi_common_config_args := \
	--enable-silent-rules \
	--enable-shared \
	--enable-static \
	--enable-pax_emutramp \
	--disable-debug

################################################################################
# Staging definitions
################################################################################

libffi_stage_config_args := $(libffi_common_config_args) \
                            --disable-docs \
                            --with-sysroot='$(stagedir)' \
                            MAKEINFO=true \
                            $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-libffi,stage-gcc)
$(call gen_check_deps,stage-libffi,stage-dejagnu)

config_stage-libffi    = $(call libffi_config_cmds,stage-libffi,\
                                                   $(stagedir),\
                                                   $(libffi_stage_config_args))
build_stage-libffi     = $(call libffi_build_cmds,stage-libffi)
clean_stage-libffi     = $(call libffi_clean_cmds,stage-libffi)
install_stage-libffi   = $(call libffi_install_cmds,stage-libffi,$(stagedir))
uninstall_stage-libffi = $(call libffi_uninstall_cmds,stage-libffi,$(stagedir))
check_stage-libffi     = $(call libffi_check_cmds,stage-libffi)

$(call gen_config_rules_with_dep,stage-libffi,libffi,config_stage-libffi)
$(call gen_clobber_rules,stage-libffi)
$(call gen_build_rules,stage-libffi,build_stage-libffi)
$(call gen_clean_rules,stage-libffi,clean_stage-libffi)
$(call gen_install_rules,stage-libffi,install_stage-libffi)
$(call gen_uninstall_rules,stage-libffi,uninstall_stage-libffi)
$(call gen_check_rules,stage-libffi,check_stage-libffi)
$(call gen_dir_rules,stage-libffi)

################################################################################
# Final definitions
################################################################################

libffi_final_config_args := $(libffi_common_config_args) \
                            --enable-docs \
                            --with-sysroot='$(finaldir)$(PREFIX)' \
                            $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-libffi,stage-gcc stage-texinfo)
$(call gen_check_deps,final-libffi,stage-dejagnu)

config_final-libffi    = $(call libffi_config_cmds,final-libffi,\
                                                   $(PREFIX),\
                                                   $(libffi_final_config_args))
build_final-libffi     = $(call libffi_build_cmds,final-libffi)
clean_final-libffi     = $(call libffi_clean_cmds,final-libffi)
install_final-libffi   = $(call libffi_install_cmds,final-libffi,\
                                                    $(PREFIX),\
                                                    $(finaldir))
uninstall_final-libffi = $(call libffi_uninstall_cmds,final-libffi,\
                                                      $(PREFIX),\
                                                      $(finaldir))
check_final-libffi     = $(call libffi_check_cmds,final-libffi)

$(call gen_config_rules_with_dep,final-libffi,libffi,config_final-libffi)
$(call gen_clobber_rules,final-libffi)
$(call gen_build_rules,final-libffi,build_final-libffi)
$(call gen_clean_rules,final-libffi,clean_final-libffi)
$(call gen_install_rules,final-libffi,install_final-libffi)
$(call gen_uninstall_rules,final-libffi,uninstall_final-libffi)
$(call gen_check_rules,final-libffi,check_final-libffi)
$(call gen_dir_rules,final-libffi)
