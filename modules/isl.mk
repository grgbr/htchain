################################################################################
# isl modules
################################################################################

isl_dist_url  := https://libisl.sourceforge.io/isl-0.24.tar.bz2
isl_dist_sum  := aab3bddbda96b801d0f56d2869f943157aad52a6f6e6a61745edd740234c635c38231af20bc3f1a08d416a5e973a90e18249078ed8e4ae2f1d5de57658738e95
isl_dist_name := $(notdir $(isl_dist_url))
isl_vers      := $(patsubst isl-%.tar.xz,%,$(isl_dist_name))
isl_brief     := Manipulating sets and relations of integer points bounded by linear constraints
isl_home      := http://libisl.sourceforge.io/

define isl_desc
isl is a library for manipulating sets and relations of integer points bounded
by linear constraints. Supported operations on sets include intersection, union,
set difference, emptiness check, convex hull, (integer) affine hull, integer
projection, and computing the lexicographic minimum using parametric integer
programming. It also includes an ILP solver based on generalized basis
reduction.
endef

define fetch_isl_dist
$(call download_csum,$(isl_dist_url),\
                     $(isl_dist_name),\
                     $(isl_dist_sum))
endef
$(call gen_fetch_rules,isl,isl_dist_name,fetch_isl_dist)

define xtract_isl
$(call rmrf,$(srcdir)/isl)
$(call untar,$(srcdir)/isl,\
             $(FETCHDIR)/$(isl_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,isl,xtract_isl)

$(call gen_dir_rules,isl)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define isl_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/isl/configure --prefix='$(strip $(2))' \
                        $(3) \
                        $(verbose)
endef

# $(1): targets base name / module name
define isl_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define isl_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define isl_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define isl_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define isl_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         LD_LIBRARY_PATH="$(stage_lib_path)"
endef

isl_common_args := --enable-silent-rules \
                   --enable-static \
                   --with-gnu-ld \
                   --with-int=gmp \
                   --without-gcc-arch

################################################################################
# Bootstrapping definitions
################################################################################

isl_bstrap_config_args := $(isl_common_args) \
                          --disable-shared \
                          --with-gmp-prefix="$(bstrapdir)" \
                          $(bstrap_config_flags)

$(call gen_deps,bstrap-isl,bstrap-gmp)

config_bstrap-isl    = $(call isl_config_cmds,bstrap-isl,\
                                              $(bstrapdir),\
                                              $(isl_bstrap_config_args))
build_bstrap-isl     = $(call isl_build_cmds,bstrap-isl)
clean_bstrap-isl     = $(call isl_clean_cmds,bstrap-isl)
install_bstrap-isl   = $(call isl_install_cmds,bstrap-isl)
uninstall_bstrap-isl = $(call isl_uninstall_cmds,bstrap-isl,$(bstrapdir))
check_bstrap-isl     = $(call isl_check_cmds,bstrap-isl)

$(call gen_config_rules_with_dep,bstrap-isl,isl,config_bstrap-isl)
$(call gen_clobber_rules,bstrap-isl)
$(call gen_build_rules,bstrap-isl,build_bstrap-isl)
$(call gen_clean_rules,bstrap-isl,clean_bstrap-isl)
$(call gen_install_rules,bstrap-isl,install_bstrap-isl)
$(call gen_uninstall_rules,bstrap-isl,uninstall_bstrap-isl)
$(call gen_check_rules,bstrap-isl,check_bstrap-isl)
$(call gen_dir_rules,bstrap-isl)

################################################################################
# Staging definitions
################################################################################

isl_stage_config_args := $(isl_common_args) \
                         --enable-shared \
                         --with-gmp-prefix="$(stagedir)" \
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

$(call gen_deps,stage-isl,stage-gmp)
$(call gen_check_deps,stage-isl,stage-gcc)

config_stage-isl    = $(call isl_config_cmds,stage-isl,\
                                             $(stagedir),\
                                             $(isl_stage_config_args))
build_stage-isl     = $(call isl_build_cmds,stage-isl)
clean_stage-isl     = $(call isl_clean_cmds,stage-isl)
install_stage-isl   = $(call isl_install_cmds,stage-isl)
uninstall_stage-isl = $(call isl_uninstall_cmds,stage-isl,$(stagedir))
check_stage-isl     = $(call isl_check_cmds,stage-isl)

$(call gen_config_rules_with_dep,stage-isl,isl,config_stage-isl)
$(call gen_clobber_rules,stage-isl)
$(call gen_build_rules,stage-isl,build_stage-isl)
$(call gen_clean_rules,stage-isl,clean_stage-isl)
$(call gen_install_rules,stage-isl,install_stage-isl)
$(call gen_uninstall_rules,stage-isl,uninstall_stage-isl)
$(call gen_check_rules,stage-isl,check_stage-isl)
$(call gen_dir_rules,stage-isl)

################################################################################
# Final definitions
################################################################################

isl_final_config_args := $(isl_common_args) \
                         --enable-shared \
                         --with-gmp-prefix="$(stagedir)" \
                         $(final_config_flags) \
                         LT_SYS_LIBRARY_PATH="$(stagedir)/lib"

$(call gen_deps,\
       final-isl,\
       stage-gmp stage-python stage-texinfo stage-perl stage-pkg-config)

config_final-isl    = $(call isl_config_cmds,final-isl,\
                                             $(PREFIX),\
                                             $(isl_final_config_args))
build_final-isl     = $(call isl_build_cmds,final-isl)
clean_final-isl     = $(call isl_clean_cmds,final-isl)
install_final-isl   = $(call isl_install_cmds,final-isl,$(finaldir))
uninstall_final-isl = $(call isl_uninstall_cmds,final-isl,\
                                                $(PREFIX),\
                                                $(finaldir))
check_final-isl     = $(call isl_check_cmds,final-isl)

$(call gen_config_rules_with_dep,final-isl,isl,config_final-isl)
$(call gen_clobber_rules,final-isl)
$(call gen_build_rules,final-isl,build_final-isl)
$(call gen_clean_rules,final-isl,clean_final-isl)
$(call gen_install_rules,final-isl,install_final-isl)
$(call gen_uninstall_rules,final-isl,uninstall_final-isl)
$(call gen_check_rules,final-isl,check_final-isl)
$(call gen_dir_rules,final-isl)
