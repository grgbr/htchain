################################################################################
# mpfr modules
################################################################################

mpfr_dist_url  := https://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.bz2
mpfr_dist_sum  := 410208ee0d48474c1c10d3d4a59decd2dfa187064183b09358ec4c4666e34d74383128436b404123b831e585d81a9176b24c7ced9d913967c5fce35d4040a0b4
mpfr_dist_name := $(notdir $(mpfr_dist_url))
mpfr_vers      := $(patsubst mpfr-%.tar.xz,%,$(mpfr_dist_name))
mpfr_brief     := Multiple precision floating-point computation
mpfr_home      := https://www.mpfr.org/

define mpfr_desc
MPFR provides a library for multiple-precision floating-point computation with
correct rounding. The computation is both efficient and has a well-defined
semantics. It copies the good ideas from the ANSI/IEEE-754 standard for
double-precision floating-point arithmetic (53-bit mantissa).
endef

define fetch_mpfr_dist
$(call download_csum,$(mpfr_dist_url),\
                     $(mpfr_dist_name),\
                     $(mpfr_dist_sum))
endef
$(call gen_fetch_rules,mpfr,mpfr_dist_name,fetch_mpfr_dist)

define xtract_mpfr
$(call rmrf,$(srcdir)/mpfr)
$(call untar,$(srcdir)/mpfr,\
             $(FETCHDIR)/$(mpfr_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,mpfr,xtract_mpfr)

$(call gen_dir_rules,mpfr)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define mpfr_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/mpfr/configure --prefix='$(strip $(2))' \
                         $(3) \
                         $(verbose)
endef

# $(1): targets base name / module name
define mpfr_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define mpfr_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define mpfr_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define mpfr_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): make arguments
define mpfr_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check $(2)
endef

mpfr_common_args        := --enable-silent-rules \
                           --enable-static \
                           --disable-assert \
                           --enable-gmp-internals \
                           --enable-thread-safe \
                           --enable-decimal-float=yes \
                           --enable-float128 \
                           --with-gnu-ld

################################################################################
# Bootstrapping definitions
################################################################################

mpfr_bstrap_config_args := $(mpfr_common_args) \
                           --disable-shared \
                           --with-gmp='$(bstrapdir)' \
                           MISSING='/bin/true' \
                           $(bstrap_config_flags)

$(call gen_deps,bstrap-mpfr,bstrap-gmp)

config_bstrap-mpfr    = $(call mpfr_config_cmds,bstrap-mpfr,\
                                                $(bstrapdir),\
                                                $(mpfr_bstrap_config_args))
build_bstrap-mpfr     = $(call mpfr_build_cmds,bstrap-mpfr)
clean_bstrap-mpfr     = $(call mpfr_clean_cmds,bstrap-mpfr)
install_bstrap-mpfr   = $(call mpfr_install_cmds,bstrap-mpfr)
uninstall_bstrap-mpfr = $(call mpfr_uninstall_cmds,bstrap-mpfr,$(bstrapdir))
check_bstrap-mpfr     = $(call mpfr_check_cmds,bstrap-mpfr)

$(call gen_config_rules_with_dep,bstrap-mpfr,mpfr,config_bstrap-mpfr)
$(call gen_clobber_rules,bstrap-mpfr)
$(call gen_build_rules,bstrap-mpfr,build_bstrap-mpfr)
$(call gen_clean_rules,bstrap-mpfr,clean_bstrap-mpfr)
$(call gen_install_rules,bstrap-mpfr,install_bstrap-mpfr)
$(call gen_uninstall_rules,bstrap-mpfr,uninstall_bstrap-mpfr)
$(call gen_check_rules,bstrap-mpfr,check_bstrap-mpfr)
$(call gen_dir_rules,bstrap-mpfr)


################################################################################
# Staging definitions
################################################################################

mpfr_stage_config_args := $(mpfr_common_args) \
                          --enable-shared \
                          --with-gmp='$(stagedir)' \
                          MISSING='/bin/true' \
                          AR='$(bstrap_ar)' \
                          NM='$(bstrap_nm)' \
                          RANLIB='$(bstrap_ranlib)' \
                          OBJCOPY='$(bstrap_objcopy)' \
                          OBJDUMP='$(bstrap_objdump)' \
                          READELF='$(bstrap_readelf)' \
                          STRIP='$(bstrap_strip)' \
                          AS='$(bstrap_as)' \
                          CC='$(bstrap_cc)' \
                          CXX='$(bstrap_cxx)' \
                          CPPFLAGS='$(stage_cppflags)' \
                          CFLAGS='$(stage_cflags)' \
                          CXXFLAGS='$(stage_cxxflags)' \
                          LDFLAGS='$(stage_ldflags)' \
                          LD_LIBRARY_PATH='$(bstrap_lib_path)'

$(call gen_deps,stage-mpfr,stage-gmp)
$(call gen_check_deps,stage-mpfr,stage-gcc)

config_stage-mpfr    = $(call mpfr_config_cmds,stage-mpfr,\
                                               $(stagedir),\
                                               $(mpfr_stage_config_args))
build_stage-mpfr     = $(call mpfr_build_cmds,stage-mpfr)
clean_stage-mpfr     = $(call mpfr_clean_cmds,stage-mpfr)
install_stage-mpfr   = $(call mpfr_install_cmds,stage-mpfr)
uninstall_stage-mpfr = $(call mpfr_uninstall_cmds,stage-mpfr,$(stagedir))
check_stage-mpfr     = $(call mpfr_check_cmds,stage-mpfr)

$(call gen_config_rules_with_dep,stage-mpfr,mpfr,config_stage-mpfr)
$(call gen_clobber_rules,stage-mpfr)
$(call gen_build_rules,stage-mpfr,build_stage-mpfr)
$(call gen_clean_rules,stage-mpfr,clean_stage-mpfr)
$(call gen_install_rules,stage-mpfr,install_stage-mpfr)
$(call gen_uninstall_rules,stage-mpfr,uninstall_stage-mpfr)
$(call gen_check_rules,stage-mpfr,check_stage-mpfr)
$(call gen_dir_rules,stage-mpfr)

################################################################################
# Final definitions
################################################################################

mpfr_final_config_args := $(mpfr_common_args) \
                          --enable-shared \
                          --with-gmp="$(stagedir)" \
                          $(final_config_flags) \
                          LT_SYS_LIBRARY_PATH="$(stagedir)/lib" \
                          LD_LIBRARY_PATH='$(stage_lib_path)'

$(call gen_deps,final-mpfr,stage-gmp stage-gcc)

config_final-mpfr    = $(call mpfr_config_cmds,final-mpfr,\
                                               $(PREFIX),\
                                               $(mpfr_final_config_args))
build_final-mpfr     = $(call mpfr_build_cmds,final-mpfr)
clean_final-mpfr     = $(call mpfr_clean_cmds,final-mpfr)
install_final-mpfr   = $(call mpfr_install_cmds,final-mpfr,$(finaldir))
uninstall_final-mpfr = $(call mpfr_uninstall_cmds,final-mpfr,\
                                                  $(PREFIX),\
                                                  $(finaldir))
check_final-mpfr     = $(call mpfr_check_cmds,final-mpfr,\
                              LD_LIBRARY_PATH='$(stage_lib_path)')

$(call gen_config_rules_with_dep,final-mpfr,mpfr,config_final-mpfr)
$(call gen_clobber_rules,final-mpfr)
$(call gen_build_rules,final-mpfr,build_final-mpfr)
$(call gen_clean_rules,final-mpfr,clean_final-mpfr)
$(call gen_install_rules,final-mpfr,install_final-mpfr)
$(call gen_uninstall_rules,final-mpfr,uninstall_final-mpfr)
$(call gen_check_rules,final-mpfr,check_final-mpfr)
$(call gen_dir_rules,final-mpfr)
