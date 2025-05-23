################################################################################
# readline modules
#
# AFAIK, there is no automatic unit testing logic provided with readline.
################################################################################

readline_dist_url  := https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz
readline_dist_sum  := 0a451d459146bfdeecc9cdd94bda6a6416d3e93abd80885a40b334312f16eb890f8618a27ca26868cebbddf1224983e631b1cbc002c1a4d1cd0d65fba9fea49a
readline_dist_name := $(notdir $(readline_dist_url))
readline_vers      := $(patsubst readline-%.tar.gz,%,$(readline_dist_name))
readline_brief     := GNU readline and history libraries
readline_home      := https://tiswww.case.edu/php/chet/readline/rltop.html

define readline_desc
The GNU Readline library provides a set of functions for use by applications
that allow users to edit command lines as they are typed in. Both Emacs and vi
editing modes are available. The Readline library includes additional functions
to maintain a list of previously-entered command lines, to recall and perhaps
reedit those lines, and perform csh-like history expansion on previous commands.

The history facilities are also placed into a separate library, the History
library, as part of the build process. The History library may be used without
Readline in applications which desire its capabilities.
endef

define fetch_readline_dist
$(call download_csum,$(readline_dist_url),\
                     $(readline_dist_name),\
                     $(readline_dist_sum))
endef
$(call gen_fetch_rules,readline,readline_dist_name,fetch_readline_dist)

define xtract_readline
$(call rmrf,$(srcdir)/readline)
$(call untar,$(srcdir)/readline,\
             $(FETCHDIR)/$(readline_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,readline,xtract_readline)

$(call gen_dir_rules,readline)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
#
# ac_cv_lib_termcap_tgetent=no: prevent from searching for tgetent() into
#                               libtermcap (use libtinfo shipped with ncurses
#                               instead)
define readline_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/readline/configure --prefix='$(strip $(2))' \
                             ac_cv_lib_termcap_tgetent=no \
                             $(3) \
                             $(verbose)
endef

# $(1): targets base name / module name
define readline_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         SHLIB_LIBS='-ltinfo' \
         $(verbose)
endef

# $(1): targets base name / module name
define readline_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define readline_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         SHLIB_LIBS='-ltinfo' \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define readline_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

readline_common_config_args := --enable-shared \
                               --enable-static \
                               --enable-multibyte \
                               --disable-install-examples

################################################################################
# Staging definitions
################################################################################

readline_stage_config_args := $(readline_common_config_args) \
                              $(stage_config_flags)

$(call gen_deps,stage-readline,stage-ncurses)

config_stage-readline    = $(call readline_config_cmds,\
                                  stage-readline,\
                                  $(stagedir),\
                                  $(readline_stage_config_args))
build_stage-readline     = $(call readline_build_cmds,stage-readline)
clean_stage-readline     = $(call readline_clean_cmds,stage-readline)
install_stage-readline   = $(call readline_install_cmds,stage-readline)
uninstall_stage-readline = $(call readline_uninstall_cmds,stage-readline,\
                                                          $(stagedir))

$(call gen_config_rules_with_dep,stage-readline,readline,config_stage-readline)
$(call gen_clobber_rules,stage-readline)
$(call gen_build_rules,stage-readline,build_stage-readline)
$(call gen_clean_rules,stage-readline,clean_stage-readline)
$(call gen_install_rules,stage-readline,install_stage-readline)
$(call gen_uninstall_rules,stage-readline,uninstall_stage-readline)
$(call gen_no_check_rules,stage-readline)
$(call gen_dir_rules,stage-readline)

################################################################################
# Final definitions
################################################################################

readline_final_config_args := $(readline_common_config_args) \
                              $(final_config_flags)

$(call gen_deps,final-readline,stage-ncurses)

config_final-readline    = $(call readline_config_cmds,\
                                  final-readline,\
                                  $(PREFIX),\
                                  $(readline_final_config_args))
build_final-readline     = $(call readline_build_cmds,final-readline)
clean_final-readline     = $(call readline_clean_cmds,final-readline)
install_final-readline   = $(call readline_install_cmds,final-readline,\
                                                        $(finaldir))
uninstall_final-readline = $(call readline_uninstall_cmds,final-readline,\
                                                          $(PREFIX),\
                                                          $(finaldir))

$(call gen_config_rules_with_dep,final-readline,readline,config_final-readline)
$(call gen_clobber_rules,final-readline)
$(call gen_build_rules,final-readline,build_final-readline)
$(call gen_clean_rules,final-readline,clean_final-readline)
$(call gen_install_rules,final-readline,install_final-readline)
$(call gen_uninstall_rules,final-readline,uninstall_final-readline)
$(call gen_no_check_rules,final-readline)
$(call gen_dir_rules,final-readline)
