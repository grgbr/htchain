################################################################################
# m4 modules
################################################################################

m4_dist_url  := https://ftp.gnu.org/gnu/m4/m4-1.4.20.tar.xz
m4_dist_sum  := dc7b4f61452e564b095010029bf6ce4246e5a03959989cd76b09eb8012db7424c52819143020fab21a3471ff57ab026d3eccbd00dd3969819208980565a9fec0
m4_dist_name := $(notdir $(m4_dist_url))
m4_vers      := $(patsubst m4-%.tar.xz,%,$(m4_dist_name))
m4_brief     := Macro processing language
m4_home      := https://www.gnu.org/software/m4/
define m4_patches
#$(call patch,$(srcdir)/m4,$(PATCHDIR)/m4-1.4.19-000-fix_198_sysval.patch,-p1)
endef

define m4_desc
GNU ``m4`` is an implementation of the traditional UNIX macro processor. It is
mostly SVR4 compatible, although it has some extensions (for example, handling
more than 9 positional parameters to macros). ``m4`` also has builtin functions
for including files, running shell commands, doing arithmetic, etc.  Autoconf
needs GNU ``m4`` for generating ``configure`` scripts, but not for running them.
endef

define fetch_m4_dist
$(call download_csum,$(m4_dist_url),\
                     $(m4_dist_name),\
                     $(m4_dist_sum))
endef
$(call gen_fetch_rules,m4,m4_dist_name,fetch_m4_dist)

define xtract_m4
$(call rmrf,$(srcdir)/m4)
$(call untar,$(srcdir)/m4,\
             $(FETCHDIR)/$(m4_dist_name),\
             --strip-components=1)
$(m4_patches)
endef
$(call gen_xtract_rules,m4,xtract_m4)

$(call gen_dir_rules,m4)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define m4_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/m4/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional make arguments
define m4_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(2) \
         $(verbose)
endef

# $(1): targets base name / module name
define m4_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define m4_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define m4_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define m4_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

m4_common_args        := --enable-silent-rules \
                         --enable-threads=posix \
                         --enable-c++ \
                         --disable-assert \
                         --enable-changeword

################################################################################
# Bootstrapping definitions
################################################################################

m4_bstrap_config_args := $(m4_common_args) \
                         --disable-nls \
                         MISSING='/bin/true' \
                         $(bstrap_config_flags)

config_bstrap-m4    = $(call m4_config_cmds,bstrap-m4,\
                                            $(bstrapdir),\
                                            $(m4_bstrap_config_args))
build_bstrap-m4     = $(call m4_build_cmds,bstrap-m4)
clean_bstrap-m4     = $(call m4_clean_cmds,bstrap-m4)
install_bstrap-m4   = $(call m4_install_cmds,bstrap-m4)
uninstall_bstrap-m4 = $(call m4_uninstall_cmds,bstrap-m4,$(bstrapdir))
check_bstrap-m4     = $(call m4_check_cmds,bstrap-m4)

$(call gen_config_rules_with_dep,bstrap-m4,m4,config_bstrap-m4)
$(call gen_clobber_rules,bstrap-m4)
$(call gen_build_rules,bstrap-m4,build_bstrap-m4)
$(call gen_clean_rules,bstrap-m4,clean_bstrap-m4)
$(call gen_install_rules,bstrap-m4,install_bstrap-m4)
$(call gen_uninstall_rules,bstrap-m4,uninstall_bstrap-m4)
$(call gen_check_rules,bstrap-m4,check_bstrap-m4)
$(call gen_dir_rules,bstrap-m4)

################################################################################
# Staging definitions
################################################################################

m4_stage_config_args := $(m4_common_args) \
                        --disable-nls \
                        MISSING='true' \
                        $(stage_config_flags)

$(call gen_deps,stage-m4,stage-gcc)

config_stage-m4    = $(call m4_config_cmds,stage-m4,\
                                           $(stagedir),\
                                           $(m4_stage_config_args))
build_stage-m4     = $(call m4_build_cmds,stage-m4)
clean_stage-m4     = $(call m4_clean_cmds,stage-m4)
install_stage-m4   = $(call m4_install_cmds,stage-m4)
uninstall_stage-m4 = $(call m4_uninstall_cmds,stage-m4,$(stagedir))
check_stage-m4     = $(call m4_check_cmds,stage-m4)

$(call gen_config_rules_with_dep,stage-m4,m4,config_stage-m4)
$(call gen_clobber_rules,stage-m4)
$(call gen_build_rules,stage-m4,build_stage-m4)
$(call gen_clean_rules,stage-m4,clean_stage-m4)
$(call gen_install_rules,stage-m4,install_stage-m4)
$(call gen_uninstall_rules,stage-m4,uninstall_stage-m4)
$(call gen_check_rules,stage-m4,check_stage-m4)
$(call gen_dir_rules,stage-m4)

################################################################################
# Final definitions
################################################################################

m4_final_config_args := $(m4_common_args) \
                        --enable-nls \
                        $(final_config_flags)

$(call gen_deps,final-m4,stage-gcc stage-texinfo)

config_final-m4    = $(call m4_config_cmds,final-m4,\
                                           $(PREFIX),\
                                           $(m4_final_config_args))
build_final-m4     = $(call m4_build_cmds,final-m4,MAKEINFO="$(stage_makeinfo)")
clean_final-m4     = $(call m4_clean_cmds,final-m4)
install_final-m4   = $(call m4_install_cmds,final-m4,$(finaldir))
uninstall_final-m4 = $(call m4_uninstall_cmds,final-m4,\
                                              $(PREFIX),\
                                              $(finaldir))
check_final-m4     = $(call m4_check_cmds,final-m4)

$(call gen_config_rules_with_dep,final-m4,m4,config_final-m4)
$(call gen_clobber_rules,final-m4)
$(call gen_build_rules,final-m4,build_final-m4)
$(call gen_clean_rules,final-m4,clean_final-m4)
$(call gen_install_rules,final-m4,install_final-m4)
$(call gen_uninstall_rules,final-m4,uninstall_final-m4)
$(call gen_check_rules,final-m4,check_final-m4)
$(call gen_dir_rules,final-m4)
