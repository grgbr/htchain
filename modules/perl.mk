################################################################################
# perl modules
#
# TODO:
# * enable socks5 support using -Dusesocks configure option ?
# * make depend onto Berkeley DB
################################################################################

perl_dist_url  := https://www.cpan.org/src/5.0/perl-5.40.2.tar.gz
perl_dist_sum  := 78a186f6511e672ebac4c4627c446d3faaeab05fd6b190a7056b8e674eea33762bf1dc7ac9d695f9959366c34ecdc4c49030d7dad29ff42d1a53ce7c5d558d10
perl_dist_name := $(notdir $(perl_dist_url))
perl_vers      := $(patsubst perl-%.tar.gz,%,$(perl_dist_name))
perl_vers_maj  := $(word 1,$(subst .,$(space),$(perl_vers)))
perl_brief     := Larry Wall\'s Practical Extraction and Report Language
perl_home      := http://dev.perl.org/
define perl_patches
#$(call patch,$(srcdir)/perl,$(PATCHDIR)/perl-5.36.0-000-fix_libperl_test_config_nm.patch,-p1)
endef

define perl_desc
Perl is a highly capable, feature-rich programming language with over 20 years
of development. Perl 5 runs on over 100 platforms from portables to mainframes.
Perl is suitable for both rapid prototyping and large scale development
projects.

Perl 5 supports many programming styles, including procedural, functional, and
object-oriented. In addition to this, it is supported by an ever-growing
collection of reusable modules which accelerate development. Some of these
modules include Web frameworks, database integration, networking protocols, and
encryption. Perl provides interfaces to C and C++ for custom extension
development.
endef

define fetch_perl_dist
$(call download_csum,$(perl_dist_url),\
                     $(perl_dist_name),\
                     $(perl_dist_sum))
endef
$(call gen_fetch_rules,perl,perl_dist_name,fetch_perl_dist)

define xtract_perl
$(call rmrf,$(srcdir)/perl)
$(call untar,$(srcdir)/perl,$(FETCHDIR)/$(perl_dist_name),--strip-components=1)
$(perl_patches)
endef
$(call gen_xtract_rules,perl,xtract_perl)

$(call gen_dir_rules,perl)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
#
# LD_LIBRARY_PATH setting is required since the internal gcc probing logic of
# perl's Configure script does not use compile / link flags passed as argument.
# See `checkccflag' usage for -fstack-protector support called from Configure
# script.
define perl_config_cmds
cd $(builddir)/$(strip $(1)) && \
env LD_LIBRARY_PATH='$(stage_lib_path)' \
$(srcdir)/perl/Configure -des \
                         -Dmksymlinks \
                         -Dprefix='$(strip $(2))' \
                         $(3) \
                         $(verbose)
endef

# $(1): targets base name / module name
define perl_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define perl_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define _perl_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(CHMOD) --recursive u+w $(strip $(3))$(strip $(2))/lib/perl$(perl_vers_maj)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define perl_install_cmds
$(call _perl_install_cmds,$(1),$(2),$(installdir)/$(strip $(1)))
$(call _perl_install_cmds,$(1),$(2),$(3))
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define perl_uninstall_cmds
$(call uninstall_from_refdir,$(installdir)/$(strip $(1)),$(2))
$(call rmrf,$(installdir)/$(strip $(1)))
endef

# $(1): targets base name / module name
define perl_check_cmds
+env LD_LIBRARY_PATH="$(stage_lib_path)" \
 $(MAKE) --directory $(builddir)/$(strip $(1)) test
endef

# As perl builds with -fstack-protector-strong by default, ensure stack
# protector is disabled if no -fstack-protector options are detected into flags
# passed in arguments.
define perl_setup_ssp
$(if $(filter -fstack-protector%,$(1)),$(1),$(1) -fno-stack-protector)
endef

perl_common_config_args := \
	-Dcf_by='$(word 1,$(subst @,$(space),$(DEBMAIL)))' \
	-Dcf_email='$(DEBMAIL)' \
	-Dusethreads \
	-Dinc_version_list=none \
	-Dar='$(stage_ar)' \
	-Dfull_ar='$(stage_ar)' \
	-Dranlib='$(stage_ranlib)' \
	-Dfull_ranlib='$(stage_ranlib)' \
	-Dnm='$(stage_nm)' \
	-Dfull_nm='$(stage_nm)' \
	-Dcc='$(stage_cc)' \
	-Doptimize=undef

################################################################################
# Staging definitions
################################################################################

perl_stage_config_args := \
	$(perl_common_config_args) \
	-Dlocincpth='$(stagedir)/include' \
	-Dloclibpth='$(subst :,$(space),$(stage_lib_path))' \
	-Dlibpth='$(subst :,$(space),$(stage_lib_path))' \
	-Dman1dir=none \
	-Dman3dir=none \
	-Dcppflags='$(stage_cppflags)' \
	-Dccflags='$(call perl_setup_ssp,$(stage_cflags))' \
	-Dldflags='$(call perl_setup_ssp,$(stage_ldflags))' \
	-Dlddlflags='-shared $(call perl_setup_ssp,$(stage_ldflags))'

$(call gen_deps,stage-perl,stage-gdbm stage-zlib stage-bzip2)

config_stage-perl    = $(call perl_config_cmds,stage-perl,\
                                               $(stagedir),\
                                               $(perl_stage_config_args))
build_stage-perl     = $(call perl_build_cmds,stage-perl)
clean_stage-perl     = $(call perl_clean_cmds,stage-perl)
install_stage-perl   = $(call perl_install_cmds,stage-perl,$(stagedir))
uninstall_stage-perl = $(call perl_uninstall_cmds,stage-perl)
check_stage-perl     = $(call perl_check_cmds,stage-perl)

$(call gen_config_rules_with_dep,stage-perl,perl,config_stage-perl)
$(call gen_clobber_rules,stage-perl)
$(call gen_build_rules,stage-perl,build_stage-perl)
$(call gen_clean_rules,stage-perl,clean_stage-perl)
$(call gen_install_rules,stage-perl,install_stage-perl)
$(call gen_uninstall_rules,stage-perl,uninstall_stage-perl)
$(call gen_check_rules,stage-perl,check_stage-perl)
$(call gen_dir_rules,stage-perl)

################################################################################
# Final definitions
################################################################################

perl_final_config_args := \
	$(perl_common_config_args) \
	-Dlocincpth='$(PREFIX)/include' \
	-Dloclibpth='$(subst :,$(space),$(final_lib_path))' \
	-Dlibpth='$(subst :,$(space),$(final_lib_path))' \
	-Dman1dir="$(PREFIX)/share/man/man1" \
	-Dman3dir="$(PREFIX)/share/man/man3" \
	-Dcppflags='$(final_cppflags)' \
	-Dccflags='$(call perl_setup_ssp,$(final_cflags))' \
	-Dldflags='$(call perl_setup_ssp,$(final_ldflags))' \
	-Dlddlflags='-shared $(call perl_setup_ssp,$(final_ldflags))'

$(call gen_deps,final-perl,stage-gdbm stage-zlib stage-bzip2)

config_final-perl    = $(call perl_config_cmds,final-perl,\
                                               $(PREFIX),\
                                               $(perl_final_config_args))
build_final-perl     = $(call perl_build_cmds,final-perl)
clean_final-perl     = $(call perl_clean_cmds,final-perl)
install_final-perl   = $(call perl_install_cmds,final-perl,\
                                                $(PREFIX),\
                                                $(finaldir))
uninstall_final-perl = $(call perl_uninstall_cmds,final-perl,$(finaldir))
check_final-perl     = $(call perl_check_cmds,final-perl)

$(call gen_config_rules_with_dep,final-perl,perl,config_final-perl)
$(call gen_clobber_rules,final-perl)
$(call gen_build_rules,final-perl,build_final-perl)
$(call gen_clean_rules,final-perl,clean_final-perl)
$(call gen_install_rules,final-perl,install_final-perl)
$(call gen_uninstall_rules,final-perl,uninstall_final-perl)
$(call gen_check_rules,final-perl,check_final-perl)
$(call gen_dir_rules,final-perl)
