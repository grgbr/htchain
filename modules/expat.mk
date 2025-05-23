################################################################################
# expat modules
################################################################################

expat_dist_url  := https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.bz2
expat_dist_sum  := ea78781ca03367a014afc1bb37c2306883b6f666d7cd90dc84a39c4abc6b7ec261636b8668540aa286c708a41dd02baae8249dc4391306da56431700460a0f23
expat_dist_name := $(notdir $(expat_dist_url))
expat_vers      := $(patsubst expat-%.tar.bz2,%,$(expat_dist_name))
expat_brief     := XML parsing C library
expat_home      := https://libexpat.github.io/

define expat_desc
Expat is a stream-oriented XML parser in which an application registers handlers
for things the parser might find in the XML document (like start tags).
endef

define fetch_expat_dist
$(call download_csum,$(expat_dist_url),\
                     $(expat_dist_name),\
                     $(expat_dist_sum))
endef
$(call gen_fetch_rules,expat,expat_dist_name,fetch_expat_dist)

define xtract_expat
$(call rmrf,$(srcdir)/expat)
$(call untar,$(srcdir)/expat,\
             $(FETCHDIR)/$(expat_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,expat,xtract_expat)

$(call gen_dir_rules,expat)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define expat_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/expat/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define expat_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define expat_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define expat_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define expat_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define expat_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

expat_common_config_args := --enable-silent-rules \
                            --enable-shared \
                            --enable-static \
                            --without-examples

################################################################################
# Staging definitions
################################################################################

expat_stage_config_args := $(expat_common_config_args) \
                           --with-sysroot='$(stagedir)' \
                           --without-docbook \
                           MAKEINFO=true \
                           $(stage_config_flags)

$(call gen_deps,stage-expat,stage-gcc)

config_stage-expat    = $(call expat_config_cmds,stage-expat,\
                                                 $(stagedir),\
                                                 $(expat_stage_config_args))
build_stage-expat     = $(call expat_build_cmds,stage-expat)
clean_stage-expat     = $(call expat_clean_cmds,stage-expat)
install_stage-expat   = $(call expat_install_cmds,stage-expat,$(stagedir))
uninstall_stage-expat = $(call expat_uninstall_cmds,stage-expat,$(stagedir))
check_stage-expat     = $(call expat_check_cmds,stage-expat)

$(call gen_config_rules_with_dep,stage-expat,expat,config_stage-expat)
$(call gen_clobber_rules,stage-expat)
$(call gen_build_rules,stage-expat,build_stage-expat)
$(call gen_clean_rules,stage-expat,clean_stage-expat)
$(call gen_install_rules,stage-expat,install_stage-expat)
$(call gen_uninstall_rules,stage-expat,uninstall_stage-expat)
$(call gen_check_rules,stage-expat,check_stage-expat)
$(call gen_dir_rules,stage-expat)

################################################################################
# Final definitions
################################################################################

expat_final_config_args := $(expat_common_config_args) \
                           --with-sysroot='$(stagedir)' \
                           --without-examples \
                           $(final_config_flags)

$(call gen_deps,final-expat,stage-gcc)

config_final-expat    = $(call expat_config_cmds,final-expat,\
                                                 $(PREFIX),\
                                                 $(expat_final_config_args))
build_final-expat     = $(call expat_build_cmds,final-expat)
clean_final-expat     = $(call expat_clean_cmds,final-expat)
install_final-expat   = $(call expat_install_cmds,final-expat,\
                                                  $(PREFIX),\
                                                  $(finaldir))
uninstall_final-expat = $(call expat_uninstall_cmds,final-expat,\
                                                    $(PREFIX),\
                                                    $(finaldir))
check_final-expat     = $(call expat_check_cmds,final-expat)

$(call gen_config_rules_with_dep,final-expat,expat,config_final-expat)
$(call gen_clobber_rules,final-expat)
$(call gen_build_rules,final-expat,build_final-expat)
$(call gen_clean_rules,final-expat,clean_final-expat)
$(call gen_install_rules,final-expat,install_final-expat)
$(call gen_uninstall_rules,final-expat,uninstall_final-expat)
$(call gen_check_rules,final-expat,check_final-expat)
$(call gen_dir_rules,final-expat)
