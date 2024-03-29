################################################################################
# jsoncpp modules
################################################################################

jsoncpp_dist_url  := https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.5.tar.gz
jsoncpp_dist_sum  := 1d06e044759b1e1a4cc4960189dd7e001a0a4389d7239a6d59295af995a553518e4e0337b4b4b817e70da5d9731a4c98655af90791b6287870b5ff8d73ad8873
jsoncpp_dist_name := jsoncpp-$(notdir $(jsoncpp_dist_url))
jsoncpp_vers      := $(patsubst jsoncpp-%.tar.gz,%,$(jsoncpp_dist_name))
jsoncpp_brief     := Library for reading and writing JSON for C++
jsoncpp_home      := https://github.com/open-source-parsers/jsoncpp

define jsoncpp_desc
jsoncpp is an implementation of a JSON reader and writer in C++. JSON
(JavaScript Object Notation) is a lightweight data-interchange format that it is
easy to parse and redable for human. It is useful for building config files,
network communications protocols, etc...

This library provides following features:

* High-level data structures for collecting data from JSON.
* Easy-to-use reader and writer.
endef

define fetch_jsoncpp_dist
$(call download_csum,$(jsoncpp_dist_url),\
                     $(jsoncpp_dist_name),\
                     $(jsoncpp_dist_sum))
endef
$(call gen_fetch_rules,jsoncpp,jsoncpp_dist_name,fetch_jsoncpp_dist)

define xtract_jsoncpp
$(call rmrf,$(srcdir)/jsoncpp)
$(call untar,$(srcdir)/jsoncpp,\
             $(FETCHDIR)/$(jsoncpp_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,jsoncpp,xtract_jsoncpp)

$(call gen_dir_rules,jsoncpp)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define jsoncpp_config_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" $(3) \
$(stage_meson) setup --prefix "$(strip $(2))" \
                     --stdsplit \
                     --buildtype release \
                     --default-library both \
                     --libdir "$(strip $(2))/lib" \
                     "$(builddir)/$(strip $(1))" \
                     "$(srcdir)/jsoncpp"
endef

# $(1): targets base name / module name
define jsoncpp_build_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
$(stage_meson) compile -C $(builddir)/$(strip $(1)) $(if $(strip $(V)),--verbose)
endef

# $(1): targets base name / module name
define jsoncpp_clean_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
$(stage_meson) compile -C $(builddir)/$(strip $(1)) \
                       --ninja-args 'clean' \
                       $(if $(strip $(V)),--verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define jsoncpp_install_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
$(stage_meson) install -C $(builddir)/$(strip $(1)) \
                       --no-rebuild \
                       $(if $(strip $(2)),--destdir "$(strip $(2))") \
                       $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define jsoncpp_uninstall_cmds
-env PATH="$(stagedir)/bin:$(PATH)" \
 $(stage_meson) compile -C $(builddir)/$(strip $(1)) \
                       --ninja-args 'uninstall' \
                       $(if $(strip $(V)),--verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define jsoncpp_check_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stage_meson) test -C $(builddir)/$(strip $(1)) \
                    --no-rebuild \
                    $(if $(strip $(V)),--verbose)
endef

################################################################################
# Staging definitions
################################################################################

jsoncpp_stage_config_args := $(call stage_config_flags,$(o_flags))

$(call gen_deps,stage-jsoncpp,stage-meson)

config_stage-jsoncpp       = $(call jsoncpp_config_cmds,\
                                    stage-jsoncpp,\
                                    $(stagedir),\
                                    $(jsoncpp_stage_config_args))
build_stage-jsoncpp        = $(call jsoncpp_build_cmds,stage-jsoncpp)
clean_stage-jsoncpp        = $(call jsoncpp_clean_cmds,stage-jsoncpp)
install_stage-jsoncpp      = $(call jsoncpp_install_cmds,stage-jsoncpp)
uninstall_stage-jsoncpp    = $(call jsoncpp_uninstall_cmds,stage-jsoncpp,\
                                                           $(stagedir))
check_stage-jsoncpp        = $(call jsoncpp_check_cmds,stage-jsoncpp)

$(call gen_config_rules_with_dep,stage-jsoncpp,jsoncpp,config_stage-jsoncpp)
$(call gen_clobber_rules,stage-jsoncpp)
$(call gen_build_rules,stage-jsoncpp,build_stage-jsoncpp)
$(call gen_clean_rules,stage-jsoncpp,clean_stage-jsoncpp)
$(call gen_install_rules,stage-jsoncpp,install_stage-jsoncpp)
$(call gen_uninstall_rules,stage-jsoncpp,uninstall_stage-jsoncpp)
$(call gen_check_rules,stage-jsoncpp,check_stage-jsoncpp)
$(call gen_dir_rules,stage-jsoncpp)

################################################################################
# Final definitions
################################################################################

jsoncpp_final_config_args := $(call final_config_flags,$(o_flags))

$(call gen_deps,final-jsoncpp,stage-meson)

config_final-jsoncpp       = $(call jsoncpp_config_cmds,\
                                    final-jsoncpp,\
                                    $(PREFIX),\
                                    $(jsoncpp_final_config_args))
build_final-jsoncpp        = $(call jsoncpp_build_cmds,final-jsoncpp)
clean_final-jsoncpp        = $(call jsoncpp_clean_cmds,final-jsoncpp)
install_final-jsoncpp      = $(call jsoncpp_install_cmds,\
                                    final-jsoncpp,\
                                    $(finaldir))
uninstall_final-jsoncpp    = $(call jsoncpp_uninstall_cmds,\
                                    final-jsoncpp,\
                                    $(PREFIX),\
                                    $(finaldir))
check_final-jsoncpp        = $(call jsoncpp_check_cmds,final-jsoncpp)

$(call gen_config_rules_with_dep,final-jsoncpp,jsoncpp,config_final-jsoncpp)
$(call gen_clobber_rules,final-jsoncpp)
$(call gen_build_rules,final-jsoncpp,build_final-jsoncpp)
$(call gen_clean_rules,final-jsoncpp,clean_final-jsoncpp)
$(call gen_install_rules,final-jsoncpp,install_final-jsoncpp)
$(call gen_uninstall_rules,final-jsoncpp,uninstall_final-jsoncpp)
$(call gen_check_rules,final-jsoncpp,check_final-jsoncpp)
$(call gen_dir_rules,final-jsoncpp)
