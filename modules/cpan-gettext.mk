cpan-gettext_dist_url  := https://cpan.metacpan.org/authors/id/P/PV/PVANDRY/gettext-1.07.tar.gz
cpan-gettext_dist_name := $(notdir $(cpan-gettext_dist_url))

define fetch_cpan-gettext_dist
$(call download,$(cpan-gettext_dist_url),$(FETCHDIR)/$(cpan-gettext_dist_name))
endef
$(call gen_fetch_rules,cpan-gettext,cpan-gettext_dist_name,fetch_cpan-gettext_dist)

define xtract_cpan-gettext
$(call rmrf,$(srcdir)/cpan-gettext)
$(call untar,$(srcdir)/cpan-gettext,\
             $(FETCHDIR)/$(cpan-gettext_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cpan-gettext,xtract_cpan-gettext)

$(call gen_dir_rules,cpan-gettext)

# $(1): targets base name / module name
define cpan-gettext_config_cmds
$(RSYNC) --archive --delete $(srcdir)/cpan-gettext/ $(builddir)/$(strip $(1))
cd $(builddir)/$(strip $(1)) && \
$(stage_perl) Makefile.PL $(verbose)
endef

# $(1): targets base name / module name
define cpan-gettext_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define cpan-gettext_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
define cpan-gettext_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) install $(verbose)
endef

define perl_get_config
$(shell $(stage_perl) -MConfig -e 'print "$$Config{'$(strip $(1))'}\n"')
endef

# $(1): targets base name / module name
# $(2): build / install prefix
define cpan-gettext_uninstall_cmds
$(call rmf,$(call perl_get_config,sitearch)/Locale/gettext.pm)
$(call rmf,$(call perl_get_config,sitearch)/auto/Locale/gettext/gettext.so)
$(call rmf,$(call perl_get_config,sitearch)/auto/Locale/gettext/.packlist)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define cpan-gettext_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) test
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cpan-gettext,stage-perl stage-gettext)

config_stage-cpan-gettext       = $(call cpan-gettext_config_cmds,\
                                         stage-cpan-gettext,\
                                         $(stagedir))
build_stage-cpan-gettext        = $(call cpan-gettext_build_cmds,\
                                         stage-cpan-gettext)
clean_stage-cpan-gettext        = $(call cpan-gettext_clean_cmds,\
                                         stage-cpan-gettext)
install_stage-cpan-gettext      = $(call cpan-gettext_install_cmds,\
                                         stage-cpan-gettext)
uninstall_stage-cpan-gettext    = $(call cpan-gettext_uninstall_cmds,\
                                         stage-cpan-gettext,\
                                         $(stagedir))
check_stage-cpan-gettext        = $(call cpan-gettext_check_cmds,\
                                         stage-cpan-gettext)

$(call gen_config_rules_with_dep,stage-cpan-gettext,cpan-gettext,config_stage-cpan-gettext)
$(call gen_clobber_rules,stage-cpan-gettext)
$(call gen_build_rules,stage-cpan-gettext,build_stage-cpan-gettext)
$(call gen_clean_rules,stage-cpan-gettext,clean_stage-cpan-gettext)
$(call gen_install_rules,stage-cpan-gettext,install_stage-cpan-gettext)
$(call gen_uninstall_rules,stage-cpan-gettext,uninstall_stage-cpan-gettext)
$(call gen_check_rules,stage-cpan-gettext,check_stage-cpan-gettext)
$(call gen_dir_rules,stage-cpan-gettext)
