################################################################################
# pkg-config modules
################################################################################

pkg-config_dist_url  := https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
pkg-config_dist_sum  := 4861ec6428fead416f5cbbbb0bbad10b9152967e481d4b0ff2eb396a9f297f552984c9bb72f6864a37dcd8fca1d9ccceda3ef18d8f121938dbe4fdf2b870fe75
pkg-config_dist_name := $(notdir $(pkg-config_dist_url))
pkg-config_vers      := $(patsubst pkg-config-%.tar.gz,%,$(pkg-config_dist_name))
pkg-config_brief     := Manage compile and link flags for libraries
pkg-config_home      := http://pkg-config.freedesktop.org

define pkg-config_desc
pkg-config is a system for managing library compile and link flags that works
with automake_ and autoconf_.

Increasingly libraries ship with ".pc" files that allow querying of the
compiler and linker flags needed to use them through the
:manpage:`pkg-config(1)` program.
endef

define fetch_pkg-config_dist
$(call download_csum,$(pkg-config_dist_url),\
                     $(pkg-config_dist_name),\
                     $(pkg-config_dist_sum))
endef
$(call gen_fetch_rules,pkg-config,pkg-config_dist_name,fetch_pkg-config_dist)

define xtract_pkg-config
$(call rmrf,$(srcdir)/pkg-config)
$(call untar,$(srcdir)/pkg-config,\
             $(FETCHDIR)/$(pkg-config_dist_name),\
             --strip-components=1)
cd $(srcdir)/pkg-config && \
	patch -p1 < $(PATCHDIR)/pkg-config-0.29-000-glib_gdate_Werror_format_nonliteral.patch
cd $(srcdir)/pkg-config && \
	patch -p1 < $(PATCHDIR)/pkg-config-0.29-001-skip_test_list_all.patch
endef
$(call gen_xtract_rules,pkg-config,xtract_pkg-config)

$(call gen_dir_rules,pkg-config)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define pkg-config_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/pkg-config/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define pkg-config_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define pkg-config_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define pkg-config_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define pkg-config_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define pkg-config_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check $(2)
endef

# --disable-host-tool: do not install link pkg-config with $host- prefix
pkg-config_common_args := --enable-silent-rules \
                          --disable-host-tool

################################################################################
# Staging definitions
################################################################################

pkg-config_stage_config_args := \
	$(pkg-config_common_args) \
	--with-sysroot='$(stagedir)' \
	--with-pc-path='$(stagedir)/lib/pkgconfig:$(stagedir)/share/pkgconfig' \
	--with-internal-glib \
	--disable-nls \
	MAKEINFO=true \
	PYTHON=':' \
	PERL=':' \
	$(filter-out PYTHON=% PERL=%,$(call $(stage_config_flags),$(rpath_flags)))

$(call gen_deps,stage-pkg-config,stage-gcc)

config_stage-pkg-config    = $(call pkg-config_config_cmds,\
                                    stage-pkg-config,\
                                    $(stagedir),\
                                    $(pkg-config_stage_config_args))
build_stage-pkg-config     = $(call pkg-config_build_cmds,stage-pkg-config)
clean_stage-pkg-config     = $(call pkg-config_clean_cmds,stage-pkg-config)
install_stage-pkg-config   = $(call pkg-config_install_cmds,stage-pkg-config)
uninstall_stage-pkg-config = $(call pkg-config_uninstall_cmds,stage-pkg-config,\
                                                              $(stagedir))
check_stage-pkg-config     = $(call pkg-config_check_cmds,stage-pkg-config)

$(call gen_config_rules_with_dep,stage-pkg-config,\
                                 pkg-config,\
                                 config_stage-pkg-config)
$(call gen_clobber_rules,stage-pkg-config)
$(call gen_build_rules,stage-pkg-config,build_stage-pkg-config)
$(call gen_clean_rules,stage-pkg-config,clean_stage-pkg-config)
$(call gen_install_rules,stage-pkg-config,install_stage-pkg-config)
$(call gen_uninstall_rules,stage-pkg-config,uninstall_stage-pkg-config)
$(call gen_check_rules,stage-pkg-config,check_stage-pkg-config)
$(call gen_dir_rules,stage-pkg-config)

################################################################################
# Final definitions
################################################################################

pkg-config_final_config_args := \
	$(pkg-config_common_args) \
	--with-sysroot='$(PREFIX)' \
	--without-internal-glib \
	--with-pc-path='$(PREFIX)/lib/pkgconfig:$(PREFIX)/share/pkgconfig' \
	--enable-nls \
	$(final_config_flags)

$(call gen_deps,final-pkg-config,stage-gcc stage-python stage-glib)

config_final-pkg-config    = $(call pkg-config_config_cmds,\
                                    final-pkg-config,\
                                    $(PREFIX),\
                                    $(pkg-config_final_config_args))
build_final-pkg-config     = $(call pkg-config_build_cmds,final-pkg-config)
clean_final-pkg-config     = $(call pkg-config_clean_cmds,final-pkg-config)
install_final-pkg-config   = $(call pkg-config_install_cmds,final-pkg-config,\
                                                            $(finaldir))
uninstall_final-pkg-config = $(call pkg-config_uninstall_cmds,\
                                    final-pkg-config,\
                                    $(PREFIX),\
                                    $(finaldir))
check_final-pkg-config     = $(call pkg-config_check_cmds,final-pkg-config,\
                                    LD_LIBRARY_PATH='$(stage_lib_path)')

$(call gen_config_rules_with_dep,final-pkg-config,\
                                 pkg-config,\
                                 config_final-pkg-config)
$(call gen_clobber_rules,final-pkg-config)
$(call gen_build_rules,final-pkg-config,build_final-pkg-config)
$(call gen_clean_rules,final-pkg-config,clean_final-pkg-config)
$(call gen_install_rules,final-pkg-config,install_final-pkg-config)
$(call gen_uninstall_rules,final-pkg-config,uninstall_final-pkg-config)
$(call gen_check_rules,final-pkg-config,check_final-pkg-config)
$(call gen_dir_rules,final-pkg-config)
