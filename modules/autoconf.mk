################################################################################
# autoconf modules
################################################################################

autoconf_dist_url  := https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz
autoconf_dist_sum  := c4e9fbd858666d3e5c3b4fe7f89aa3e8e3a0a00dc7e166f8147d937d911b77ba3ac6a016f9d223ccdd830bc8960b3e60397c0607cc6a1fd2c50c7492839ddd17
autoconf_dist_name := $(notdir $(autoconf_dist_url))
autoconf_vers      := $(patsubst autoconf-%.tar.xz,%,$(autoconf_dist_name))
autoconf_brief     := Automatic configure script builder
autoconf_home      := https://www.gnu.org/software/autoconf/
define autoconf_patches
# $(call patch,$(srcdir)/autoconf),$(PATCHDIR)/autoconf-2.71-000-fix_test_env.patch,-p1)
endef

define autoconf_desc
The standard for FSF source packages. This is only useful if you write your own
programs or if you extensively modify other people\'s programs.
endef

define fetch_autoconf_dist
$(call download_csum,$(autoconf_dist_url),\
                     $(autoconf_dist_name),\
                     $(autoconf_dist_sum))
endef
$(call gen_fetch_rules,autoconf,autoconf_dist_name,fetch_autoconf_dist)

define xtract_autoconf
$(call rmrf,$(srcdir)/autoconf)
$(call untar,$(srcdir)/autoconf,\
             $(FETCHDIR)/$(autoconf_dist_name),\
             --strip-components=1)
$(autoconf_patches)
endef
$(call gen_xtract_rules,autoconf,xtract_autoconf)

$(call gen_dir_rules,autoconf)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define autoconf_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/autoconf/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define autoconf_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         PATH="$(stagedir)/bin:$(PATH)" \
         $(verbose)
endef

# $(1): targets base name / module name
define autoconf_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define autoconf_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define autoconf_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define autoconf_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH="$(stagedir)/bin:$(PATH)" $(2)
endef

################################################################################
# Stage definitions
################################################################################

autoconf_stage_config_args  = --enable-silent-rules \
                              $(stage_config_flags)

$(call gen_deps,stage-autoconf,stage-m4 stage-perl)

config_stage-autoconf       = $(call autoconf_config_cmds,\
                                     stage-autoconf,\
                                     $(stagedir),\
                                     $(autoconf_stage_config_args))
build_stage-autoconf        = $(call autoconf_build_cmds,stage-autoconf)
clean_stage-autoconf        = $(call autoconf_clean_cmds,stage-autoconf)
install_stage-autoconf      = $(call autoconf_install_cmds,stage-autoconf)
uninstall_stage-autoconf    = $(call autoconf_uninstall_cmds,stage-autoconf,\
                                                             $(stagedir))
check_stage-autoconf        = $(call autoconf_check_cmds,stage-autoconf)

$(call gen_config_rules_with_dep,stage-autoconf,autoconf,config_stage-autoconf)
$(call gen_clobber_rules,stage-autoconf)
$(call gen_build_rules,stage-autoconf,build_stage-autoconf)
$(call gen_clean_rules,stage-autoconf,clean_stage-autoconf)
$(call gen_install_rules,stage-autoconf,install_stage-autoconf)
$(call gen_uninstall_rules,stage-autoconf,uninstall_stage-autoconf)
$(call gen_check_rules,stage-autoconf,check_stage-autoconf)
$(call gen_dir_rules,stage-autoconf)

################################################################################
# Final definitions
################################################################################

autoconf_final_config_args  = --enable-silent-rules \
                              $(final_config_flags) \
                              ac_cv_path_PERL="$(stage_perl)"

$(call gen_deps,final-autoconf,stage-m4 stage-perl)

config_final-autoconf       = $(call autoconf_config_cmds,\
                                     final-autoconf,\
                                     $(PREFIX),\
                                     $(autoconf_final_config_args))
build_final-autoconf        = $(call autoconf_build_cmds,final-autoconf)
clean_final-autoconf        = $(call autoconf_clean_cmds,final-autoconf)

final-autoconf_perl_fixups := bin/ifnames \
                              bin/autoheader \
                              bin/autom4te \
                              bin/autoupdate \
                              bin/autoscan \
                              bin/autoreconf

define fixup_final-autoconf_perl_interp
$(SED) --in-place 's;$(stage_perl);$(PREFIX)/bin/perl;g' \
       $(addprefix $(finaldir)$(PREFIX)/,$(1))
endef

define install_final-autoconf
$(call autoconf_install_cmds,final-autoconf,$(finaldir))
$(call fixup_final-autoconf_perl_interp,$(final-autoconf_perl_fixups))
endef

uninstall_final-autoconf    = $(call autoconf_uninstall_cmds,final-autoconf,\
                                                             $(PREFIX),\
                                                             $(finaldir))
check_final-autoconf        = $(call autoconf_check_cmds,final-autoconf,\
                                     LD_LIBRARY_PATH='$(stage_lib_path)')

$(call gen_config_rules_with_dep,final-autoconf,autoconf,config_final-autoconf)
$(call gen_clobber_rules,final-autoconf)
$(call gen_build_rules,final-autoconf,build_final-autoconf)
$(call gen_clean_rules,final-autoconf,clean_final-autoconf)
$(call gen_install_rules,final-autoconf,install_final-autoconf)
$(call gen_uninstall_rules,final-autoconf,uninstall_final-autoconf)
$(call gen_check_rules,final-autoconf,check_final-autoconf)
$(call gen_dir_rules,final-autoconf)
