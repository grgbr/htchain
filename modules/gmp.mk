################################################################################
# gmp modules
################################################################################

gmp_dist_url  := https://gmplib.org/download/gmp/gmp-6.2.1.tar.bz2
gmp_dist_sum  := 8904334a3bcc5c896ececabc75cda9dec642e401fb5397c4992c4fabea5e962c9ce8bd44e8e4233c34e55c8010cc28db0545f5f750cbdbb5f00af538dc763be9
gmp_dist_name := $(notdir $(gmp_dist_url))
gmp_vers      := $(patsubst gmp-%.tar.lz,%,$(gmp_dist_name))
gmp_brief     := Multiprecision arithmetic library
gmp_home      := http://gmplib.org/

define gmp_desc
GNU MP is a programmer\'s library for arbitrary precision arithmetic (ie, a
bignum package).  It can operate on signed integer, rational, and floating point
numeric types.

It has a rich set of functions, and the functions have a regular interface.
endef

define fetch_gmp_dist
$(call download_csum,$(gmp_dist_url),\
                     $(gmp_dist_name),\
                     $(gmp_dist_sum))
endef
$(call gen_fetch_rules,gmp,gmp_dist_name,fetch_gmp_dist)

define xtract_gmp
$(call rmrf,$(srcdir)/gmp)
$(call untar,$(srcdir)/gmp,\
             $(FETCHDIR)/$(gmp_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,gmp,xtract_gmp)

$(call gen_dir_rules,gmp)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gmp_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/gmp/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define gmp_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define gmp_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define gmp_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gmp_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define gmp_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

gmp_common_args := --enable-silent-rules \
                   --disable-assert \
                   --enable-cxx \
                   --enable-assembly \
                   --enable-fft \
                   --enable-fat \
                   --enable-static \
                   --with-gnu-ld \
                   $(if $(mach_is_64bits),ABI=64)

################################################################################
# Bootstrapping definitions
################################################################################

gmp_bstrap_config_args := $(gmp_common_args) \
                          --disable-shared \
                          MISSING='/bin/true' \
                          $(bstrap_config_flags)

$(call gen_deps,bstrap-gmp,bstrap-m4)

config_bstrap-gmp    = $(call gmp_config_cmds,bstrap-gmp,\
                                              $(bstrapdir),\
                                              $(gmp_bstrap_config_args))
build_bstrap-gmp     = $(call gmp_build_cmds,bstrap-gmp)
clean_bstrap-gmp     = $(call gmp_clean_cmds,bstrap-gmp)
install_bstrap-gmp   = $(call gmp_install_cmds,bstrap-gmp)
uninstall_bstrap-gmp = $(call gmp_uninstall_cmds,bstrap-gmp,$(bstrapdir))
check_bstrap-gmp     = $(call gmp_check_cmds,bstrap-gmp)

$(call gen_config_rules_with_dep,bstrap-gmp,gmp,config_bstrap-gmp)
$(call gen_clobber_rules,bstrap-gmp)
$(call gen_build_rules,bstrap-gmp,build_bstrap-gmp)
$(call gen_clean_rules,bstrap-gmp,clean_bstrap-gmp)
$(call gen_install_rules,bstrap-gmp,install_bstrap-gmp)
$(call gen_uninstall_rules,bstrap-gmp,uninstall_bstrap-gmp)
$(call gen_check_rules,bstrap-gmp,check_bstrap-gmp)
$(call gen_dir_rules,bstrap-gmp)

################################################################################
# Staging definitions
################################################################################

gmp_stage_config_args := $(gmp_common_args) \
                         --enable-shared \
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
                         M4='$(bstrap_m4)' \
                         CPPFLAGS='$(stage_cppflags)' \
                         CFLAGS='$(stage_cflags)' \
                         CXXFLAGS='$(stage_cxxflags)' \
                         LDFLAGS='$(stage_ldflags)' \
                         LD_LIBRARY_PATH='$(bstrap_lib_path)'

$(call gen_deps,stage-gmp,bstrap-gcc bstrap-m4)
$(call gen_check_deps,stage-gmp,stage-gcc)

config_stage-gmp    = $(call gmp_config_cmds,stage-gmp,\
                                             $(stagedir),\
                                             $(gmp_stage_config_args))
build_stage-gmp     = $(call gmp_build_cmds,stage-gmp)
clean_stage-gmp     = $(call gmp_clean_cmds,stage-gmp)
install_stage-gmp   = $(call gmp_install_cmds,stage-gmp)
uninstall_stage-gmp = $(call gmp_uninstall_cmds,stage-gmp,$(stagedir))
check_stage-gmp     = $(call gmp_check_cmds,stage-gmp)

$(call gen_config_rules_with_dep,stage-gmp,gmp,config_stage-gmp)
$(call gen_clobber_rules,stage-gmp)
$(call gen_build_rules,stage-gmp,build_stage-gmp)
$(call gen_clean_rules,stage-gmp,clean_stage-gmp)
$(call gen_install_rules,stage-gmp,install_stage-gmp)
$(call gen_uninstall_rules,stage-gmp,uninstall_stage-gmp)
$(call gen_check_rules,stage-gmp,check_stage-gmp)
$(call gen_dir_rules,stage-gmp)

################################################################################
# Final definitions
################################################################################

gmp_final_config_args := $(gmp_common_args) \
                         --enable-shared \
                         --with-gnu-ld \
                         $(final_config_flags)

$(call gen_deps,final-gmp,stage-gcc stage-m4 stage-flex stage-chrpath)

config_final-gmp    = $(call gmp_config_cmds,final-gmp,\
                                             $(PREFIX),\
                                             $(gmp_final_config_args))
build_final-gmp     = $(call gmp_build_cmds,final-gmp)
clean_final-gmp     = $(call gmp_clean_cmds,final-gmp)

# Replace final RPATH since libgmpxx contains a reference to staging library
# path at post install time
define install_final-gmp
$(call gmp_install_cmds,final-gmp,$(finaldir))
$(call fixup_rpath,$(finaldir)$(PREFIX)/lib/libgmpxx.so,\
                   $(final_lib_path))
endef

uninstall_final-gmp = $(call gmp_uninstall_cmds,final-gmp,\
                                                $(PREFIX),\
                                                $(finaldir))
check_final-gmp     = $(call gmp_check_cmds,final-gmp)

$(call gen_config_rules_with_dep,final-gmp,gmp,config_final-gmp)
$(call gen_clobber_rules,final-gmp)
$(call gen_build_rules,final-gmp,build_final-gmp)
$(call gen_clean_rules,final-gmp,clean_final-gmp)
$(call gen_install_rules,final-gmp,install_final-gmp)
$(call gen_uninstall_rules,final-gmp,uninstall_final-gmp)
$(call gen_check_rules,final-gmp,check_final-gmp)
$(call gen_dir_rules,final-gmp)
