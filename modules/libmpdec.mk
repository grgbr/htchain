################################################################################
# libmpdec modules
################################################################################

libmpdec_dist_url  := https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-4.0.1.tar.gz
libmpdec_dist_sum  := 431fa8ab90d6b8cdecc38b1618fd89d040185dec3c1150203e20f40f10a16160058f6b8abddd000f6ecb74f4dc42d9fef8111444f1496ab34c34f6b814ed32b7
libmpdec_dist_name := $(subst mpdecimal,libmpdec,$(notdir $(libmpdec_dist_url)))
libmpdec_vers      := $(patsubst libmpdec-%.tar.gz,%,$(libmpdec_dist_name))
libmpdec_brief     := Library for decimal floating point arithmetic
libmpdec_home      := https://www.bytereef.org/mpdecimal/index.html
define libmpdec_patches
#$(call patch,$(srcdir)/libmpdec,$(PATCHDIR)/libmpdec-2.5.1-000-fix_runtest_lib_path.patch,-p1)
endef

define libmpdec_desc
mpdecimal is a package for correctly-rounded arbitrary precision decimal
floating point arithmetic.
endef

define fetch_libmpdec_dist
$(call download_csum,$(libmpdec_dist_url),\
                     $(libmpdec_dist_name),\
                     $(libmpdec_dist_sum))
endef
$(call gen_fetch_rules,libmpdec,libmpdec_dist_name,fetch_libmpdec_dist)

libmpdec_test_dist_url  := http://speleotrove.com/decimal/dectest.zip
libmpdec_test_dist_sum  := 05f9d12aec1ebfc9ca211b01705b41c5cd1bbc54d9aa6c4799b40fb3ab1835433fd1a277735d26d2530c3793c58b107b3abb1c31f64340e5e9d7856d92c821cf
libmpdec_test_dist_name := libmpdec-test.zip

define fetch_libmpdec_test_dist
$(call download_csum,$(libmpdec_test_dist_url),\
                     $(libmpdec_test_dist_name),\
                     $(libmpdec_test_dist_sum))
endef
$(call gen_fetch_rules,libmpdec,\
                       libmpdec_test_dist_name,\
                       fetch_libmpdec_test_dist)

define xtract_libmpdec
$(call rmrf,$(srcdir)/libmpdec)
$(call untar,$(srcdir)/libmpdec,\
             $(FETCHDIR)/$(libmpdec_dist_name),\
             --strip-components=1)
$(call mkdir,$(srcdir)/libmpdec/tests/testdata)
$(UNZIP) -d $(srcdir)/libmpdec/tests/testdata \
         $(FETCHDIR)/$(libmpdec_test_dist_name)
$(libmpdec_patches)
endef
$(call gen_xtract_rules,libmpdec,xtract_libmpdec)

$(call gen_dir_rules,libmpdec)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libmpdec_config_cmds
$(RSYNC) --archive --delete $(srcdir)/libmpdec/ $(builddir)/$(strip $(1))
cd $(builddir)/$(strip $(1)) && \
./configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libmpdec_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) $(verbose)
endef

# $(1): targets base name / module name
define libmpdec_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define _libmpdec_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libmpdec_install_cmds
$(call _libmpdec_install_cmds,$(1),$(installdir)/$(strip $(1)))
$(call _libmpdec_install_cmds,$(1),$(2))
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libmpdec_uninstall_cmds
$(call uninstall_from_refdir,$(installdir)/$(strip $(1)),$(2))
$(call rmrf,$(installdir)/$(strip $(1)))
endef

# $(1): targets base name / module name
define libmpdec_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         LD_LIBRARY_PATH="$(stage_lib_path)"
endef

libmpdec_common_config_args := --enable-shared \
                               --enable-cxx

################################################################################
# Staging definitions
################################################################################

libmpdec_stage_config_args := $(libmpdec_common_config_args) \
                              $(call stage_config_flags,$(rpath_flags)) \
                              LDXXFLAGS="$(stage_ldflags)"

$(call gen_deps,stage-libmpdec,stage-gcc)

config_stage-libmpdec    = $(call libmpdec_config_cmds,\
                                 stage-libmpdec,\
                                 $(stagedir),\
                                 $(libmpdec_stage_config_args))
build_stage-libmpdec     = $(call libmpdec_build_cmds,stage-libmpdec)
clean_stage-libmpdec     = $(call libmpdec_clean_cmds,stage-libmpdec)
install_stage-libmpdec   = $(call libmpdec_install_cmds,stage-libmpdec)
uninstall_stage-libmpdec = $(call libmpdec_uninstall_cmds,stage-libmpdec)
check_stage-libmpdec     = $(call libmpdec_check_cmds,stage-libmpdec)

$(call gen_config_rules_with_dep,stage-libmpdec,libmpdec,config_stage-libmpdec)
$(call gen_clobber_rules,stage-libmpdec)
$(call gen_build_rules,stage-libmpdec,build_stage-libmpdec)
$(call gen_clean_rules,stage-libmpdec,clean_stage-libmpdec)
$(call gen_install_rules,stage-libmpdec,install_stage-libmpdec)
$(call gen_uninstall_rules,stage-libmpdec,uninstall_stage-libmpdec)
$(call gen_check_rules,stage-libmpdec,check_stage-libmpdec)
$(call gen_dir_rules,stage-libmpdec)

################################################################################
# Final definitions
################################################################################

libmpdec_final_config_args := $(libmpdec_common_config_args) \
                              $(call final_config_flags,$(rpath_flags)) \
                              LDXXFLAGS="$(final_ldflags)"

$(call gen_deps,final-libmpdec,stage-gcc)

config_final-libmpdec    = $(call libmpdec_config_cmds,\
                                 final-libmpdec,\
                                 $(PREFIX),\
                                 $(libmpdec_final_config_args))
build_final-libmpdec     = $(call libmpdec_build_cmds,final-libmpdec)
clean_final-libmpdec     = $(call libmpdec_clean_cmds,final-libmpdec)
install_final-libmpdec   = $(call libmpdec_install_cmds,final-libmpdec,\
                                                        $(finaldir))
uninstall_final-libmpdec = $(call libmpdec_uninstall_cmds,final-libmpdec,\
                                                          $(finaldir))
check_final-libmpdec     = $(call libmpdec_check_cmds,final-libmpdec)

$(call gen_config_rules_with_dep,final-libmpdec,libmpdec,config_final-libmpdec)
$(call gen_clobber_rules,final-libmpdec)
$(call gen_build_rules,final-libmpdec,build_final-libmpdec)
$(call gen_clean_rules,final-libmpdec,clean_final-libmpdec)
$(call gen_install_rules,final-libmpdec,install_final-libmpdec)
$(call gen_uninstall_rules,final-libmpdec,uninstall_final-libmpdec)
$(call gen_check_rules,final-libmpdec,check_final-libmpdec)
$(call gen_dir_rules,final-libmpdec)
