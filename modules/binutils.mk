################################################################################
# binutils modules
################################################################################

binutils_dist_url  := https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.lz
binutils_dist_sum  := 87f1b5017ed2702a1af8f07f0ddd110289df56ec70643813b3e31922c01de590922ce3009f0dbc149ea4074dbe2f0927ec8ec83aeedd83734b7523a4e3221cff
binutils_dist_name := $(notdir $(binutils_dist_url))
binutils_vers      := $(patsubst binutils-%.tar.lz,%,$(binutils_dist_name))
binutils_brief     := GNU assembler, linker and binary utilities
binutils_home      := https://www.gnu.org/software/binutils/

define binutils_desc
The programs in this package are used to assemble, link and manipulate binary
and object files. They may be used in conjunction with a compiler and various
libraries to build programs.
endef

define fetch_binutils_dist
$(call download_csum,$(binutils_dist_url),\
                     $(binutils_dist_name),\
                     $(binutils_dist_sum))
endef
$(call gen_fetch_rules,binutils,binutils_dist_name,fetch_binutils_dist)

define xtract_binutils
$(call rmrf,$(srcdir)/binutils)
$(call untar,$(srcdir)/binutils,\
             $(FETCHDIR)/$(binutils_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,binutils,xtract_binutils)

$(call gen_dir_rules,binutils)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define binutils_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/binutils/configure --prefix='$(strip $(2))' \
                             $(3) \
                             $(verbose)
endef

# $(1): targets base name / module name
# $(2): make arguments
define binutils_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(2) \
         $(verbose) V=1
endef

# $(1): targets base name / module name
define binutils_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): make arguments
define binutils_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(2) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define binutils_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define binutils_check_cmds
+$(MAKE) -j1 \
         --directory $(builddir)/$(strip $(1)) \
         check \
         MAKEINFO='/bin/true' \
         EXPECT='$(stage_expect)' \
         RUNTEST='$(stage_runtest)' \
         CFLAGS_FOR_TARGET='$(filter-out $(lto_flags),$(stage_cflags))' \
         CXXFLAGS_FOR_TARGET='$(filter-out $(lto_flags),$(stage_cxxflags))' \
         $(2)
endef

binutils_x86_64_args := --enable-x86-relax-relocations \
                        --enable-x86-used-note \
                        --disable-softfloat \
                        --enable-64-bit-bfd

binutils_common_args := --enable-silent-rules \
                        --enable-plugins \
                        --enable-checking \
                        --disable-multilib \
                        --enable-ld=default \
                        --disable-gold \
                        --enable-threads \
                        --enable-deterministic-archives \
                        --enable-new-dtags \
                        --enable-initfini-array \
                        --enable-default-hash-style=gnu \
                        --enable-separate-code \
                        --enable-relro \
                        --enable-textrel-check=yes \
                        --enable-error-handling-script \
                        --enable-install-libbfd \
                        --enable-install-libiberty \
                        $(if $(arch_is_x86_64),$(binutils_x86_64_args))

################################################################################
# Bootstrapping definitions
################################################################################

binutils_bstrap_config_args := $(binutils_common_args) \
                               --without-debuginfod \
                               --disable-nls \
                               --without-system-zlib \
                               MAKEINFO='/bin/true' \
                               $(bstrap_config_flags)

$(call gen_check_deps,bstrap-binutils,stage-dejagnu)

config_bstrap-binutils    = $(call binutils_config_cmds,\
                                   bstrap-binutils,\
                                   $(bstrapdir),\
                                   $(binutils_bstrap_config_args))
build_bstrap-binutils     = $(call binutils_build_cmds,bstrap-binutils,\
                                                       MAKEINFO='/bin/true')
clean_bstrap-binutils     = $(call binutils_clean_cmds,bstrap-binutils)
install_bstrap-binutils   = $(call binutils_install_cmds,bstrap-binutils,\
                                                         MAKEINFO='/bin/true')
uninstall_bstrap-binutils = $(call binutils_uninstall_cmds,bstrap-binutils,\
                                                           $(bstrapdir))
check_bstrap-binutils     = $(call binutils_check_cmds,bstrap-binutils)

$(call gen_config_rules_with_dep,bstrap-binutils,\
                                 binutils,\
                                 config_bstrap-binutils)
$(call gen_clobber_rules,bstrap-binutils)
$(call gen_build_rules,bstrap-binutils,build_bstrap-binutils)
$(call gen_clean_rules,bstrap-binutils,clean_bstrap-binutils)
$(call gen_install_rules,bstrap-binutils,install_bstrap-binutils)
$(call gen_uninstall_rules,bstrap-binutils,uninstall_bstrap-binutils)
$(call gen_check_rules,bstrap-binutils,check_bstrap-binutils)
$(call gen_dir_rules,bstrap-binutils)

################################################################################
# Staging definitions
################################################################################

# ac_cv_libctf_tcl_try=yes:
# Ensure libctl configure script results with complete TCL / DejaGNU support so
# that libctf testsuite are run with the right DejaGNU environment.
# See `check-DEJAGNU' target definition in <binutils>/libctf/Makefile.am file
# which is conditionally generated if TCL_TRY make variable (derived from
# ac_cv_libctf_tcl_try configure variable) is on only.
binutils_stage_flags       := MAKEINFO='/bin/true' \
                              ac_cv_libctf_tcl_try=yes \
                              LD_LIBRARY_PATH='$(bstrap_lib_path)'

binutils_stage_config_args := $(binutils_common_args) \
                              --without-debuginfod \
                              --disable-nls \
                              --without-system-zlib \
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
                              ac_cv_libctf_tcl_try=yes \
                              $(binutils_stage_flags)

$(call gen_deps,stage-binutils,bstrap-gcc)
$(call gen_check_deps,stage-binutils,stage-dejagnu)

config_stage-binutils    = $(call binutils_config_cmds,\
                                  stage-binutils,\
                                  $(stagedir),\
                                  $(binutils_stage_config_args))
build_stage-binutils     = $(call binutils_build_cmds,\
                                  stage-binutils,\
                                  $(binutils_stage_flags))
clean_stage-binutils     = $(call binutils_clean_cmds,stage-binutils)
install_stage-binutils   = $(call binutils_install_cmds,\
                                  stage-binutils,\
                                  $(binutils_stage_flags))
uninstall_stage-binutils = $(call binutils_uninstall_cmds,stage-binutils,\
                                                          $(stagedir))
check_stage-binutils     = $(call binutils_check_cmds,stage-binutils)

$(call gen_config_rules_with_dep,stage-binutils,binutils,config_stage-binutils)
$(call gen_clobber_rules,stage-binutils)
$(call gen_build_rules,stage-binutils,build_stage-binutils)
$(call gen_clean_rules,stage-binutils,clean_stage-binutils)
$(call gen_install_rules,stage-binutils,install_stage-binutils)
$(call gen_uninstall_rules,stage-binutils,uninstall_stage-binutils)
$(call gen_check_rules,stage-binutils,check_stage-binutils)
$(call gen_dir_rules,stage-binutils)

################################################################################
# Final definitions
################################################################################

# PATH:
# Tell make where to find binary tools ; this is required since tools are not
# explicitly specified at configure time
#
# lt_cv_sys_lib_dlsearch_path_spec="$(_stage_lib_path)":
# Tell libtool that the runtime dynamic linker searches for library within the
# path passed in argument by default.
# This allows to remove the given path from the RUNPATH field of ELF objects
# generated at build / install time.
binutils_final_flags       := PATH="$(stagedir)/bin:$(PATH)" \
                              lt_cv_sys_lib_dlsearch_path_spec="$(_stage_lib_path)"

binutils_final_config_args := $(binutils_common_args) \
                              --with-pkgversion='$(pkgvers)' \
                              --with-bugurl='$(pkgurl)' \
                              --with-system-zlib \
                              --enable-nls \
                              $(final_config_flags) \

$(call gen_deps,final-binutils,stage-gcc \
                               stage-flex \
                               stage-texinfo \
                               stage-expect \
                               stage-help2man)
$(call gen_check_deps,final-binutils,stage-dejagnu)

config_final-binutils    = $(call binutils_config_cmds,\
                                  final-binutils,\
                                  $(PREFIX),\
                                  $(binutils_final_config_args))
build_final-binutils     = $(call binutils_build_cmds,\
                                  final-binutils,\
                                  $(binutils_final_flags))
clean_final-binutils     = $(call binutils_clean_cmds,final-binutils)
install_final-binutils   = $(call binutils_install_cmds,final-binutils,\
                                                        DESTDIR='$(finaldir)')
uninstall_final-binutils = $(call binutils_uninstall_cmds,final-binutils,\
                                                          $(PREFIX),\
                                                          $(finaldir))
check_final-binutils     = $(call binutils_check_cmds,final-binutils,\
                                  LD_LIBRARY_PATH='$(stage_lib_path)')

$(call gen_config_rules_with_dep,final-binutils,binutils,config_final-binutils)
$(call gen_clobber_rules,final-binutils)
$(call gen_build_rules,final-binutils,build_final-binutils)
$(call gen_clean_rules,final-binutils,clean_final-binutils)
$(call gen_install_rules,final-binutils,install_final-binutils)
$(call gen_uninstall_rules,final-binutils,uninstall_final-binutils)
$(call gen_check_rules,final-binutils,check_final-binutils)
$(call gen_dir_rules,final-binutils)
