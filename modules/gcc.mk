################################################################################
# gcc modules
################################################################################

gcc_dist_url  := https://ftpmirror.gnu.org/gnu/gcc/gcc-14.3.0/gcc-14.3.0.tar.xz
gcc_dist_sum  := cb4e3259640721bbd275c723fe4df53d12f9b1673afb3db274c22c6aa457865dccf2d6ea20b4fd4c591f6152e6d4b87516c402015900f06ce9d43af66d3b7a93
gcc_dist_name := $(notdir $(gcc_dist_url))
gcc_vers      := $(patsubst gcc-%.tar.xz,%,$(gcc_dist_name))
gcc_brief     := GNU compiler collection
gcc_home      := https://gcc.gnu.org/

define gcc_desc
The GNU Compiler Collection includes front ends for C, C++, Objective-C,
Fortran, Ada, Go, and D, as well as libraries for these languages
(libstdc++,...). GCC was originally written as the compiler for the GNU
operating system. The GNU system was developed to be 100% free software, free in
the sense that it respects the user\'s freedom.

We strive to provide regular, high quality releases, which we want to work well
on a variety of native and cross targets (including GNU/Linux), and encourage
everyone to contribute changes or help testing GCC. Our sources are readily and
freely available via Git and weekly snapshots.
endef

define fetch_gcc_dist
$(call download_csum,$(gcc_dist_url),\
                     $(gcc_dist_name),\
                     $(gcc_dist_sum))
endef
$(call gen_fetch_rules,gcc,gcc_dist_name,fetch_gcc_dist)

define xtract_gcc
$(call rmrf,$(srcdir)/gcc)
$(call untar,$(srcdir)/gcc,\
             $(FETCHDIR)/$(gcc_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,gcc,xtract_gcc)

$(call gen_dir_rules,gcc)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gcc_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/gcc/configure --prefix='$(strip $(2))' \
                        $(3) \
                        $(verbose)
endef

# $(1): targets base name / module name
# $(2): make arguments
define gcc_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(2) $(verbose)
endef

# $(1): targets base name / module name
define gcc_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
define gcc_vers_cmd :=
$(bstrap_cc) --version | \
	sed -n \
	    -e '1s/.*[[:blank:]]\+\([0-9.]\+\)$$/\1/' \
	    -e 's/^\([0-9]\+\).*/\1/p'
endef

# $(1): targets base name / module name
define gcc_uplet_cmd :=
$(bstrap_cc) -dumpmachine
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gcc_install_plugins_cmds
gcc_uplet=$$($(gcc_uplet_cmd)); \
gcc_vers=$$($(gcc_vers_cmd)); \
$(call mkdir,$(strip $(3))$(strip $(2))/lib/bfd-plugins); \
$(call slink,\
       ../../libexec/gcc/$$gcc_uplet/$$gcc_vers/liblto_plugin.so,\
       $(strip $(3))$(strip $(2))/lib/bfd-plugins/liblto_plugin.so); \
$(call mkdir,$(strip $(3))$(strip $(2))/$$gcc_uplet/lib/bfd-plugins); \
$(call slink,\
       ../../../libexec/gcc/$$gcc_uplet/$$gcc_vers/liblto_plugin.so,\
       $(strip $(3))$(strip $(2))/$$gcc_uplet/lib/bfd-plugins/liblto_plugin.so)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
# $(4): make arguments
define gcc_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(4) \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(call gcc_install_plugins_cmds,$(strip $(1)),$(strip $(2)),$(strip $(3)))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gcc_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define gcc_check_cmds
+env PATH="$(stagedir)/bin:$(PATH)" \
 $(MAKE) -j1 --directory $(builddir)/$(strip $(1)) check $(2)
endef

# Do not include --enable-cet since failing to build with gcc-7 at bootstrapping
# time. Do not enable it during stage / final steps since we do not build a
# hardened toolchain anyway.
# --enable-cet: fails to build with old gcc
gcc_common_x86_64_args := --with-arch=native \
                          --with-cpu=native \
                          --with-tune=native \
                          --with-fpmath=avx \
                          --disable-softfloat

# --enable-checking= (with = + empty): force enable checking but is = is missing
# the config set it to "yes" and not "release" setting mode. Moreover for 
# stage1 checking for LTO the configuration must be (See PR62077)
# release,misc,gimple,rtlflag,tree and release for other.
gcc_common_args        := --enable-silent-rules \
                          --enable-shared \
                          --enable-clocale=gnu \
                          --enable-checking= \
                          --disable-multilib \
                          --with-gnu-as \
                          --with-gnu-ld \
                          --with-gcc-major-version-only \
                          --enable-linker-build-id \
                          --enable-link-serialization \
                          --enable-plugin \
                          --enable-threads=posix \
                          --enable-tls \
                          --enable-decimal-float=yes \
                          --enable-default-pie \
                          --disable-vtable-verify \
                          --enable-default-ssp \
                          --enable-libssp \
                          --enable-lto \
                          --enable-default-hash-style=gnu \
                          --with-linker-hash-style=gnu \
                          --enable-gnu-unique-object \
                          --without-cuda-driver \
                          --with-pkgversion='$(pkgvers)' \
                          --with-glibc-version='$(libc_vers)' \
                          $(if $(arch_is_x86_64),$(gcc_common_x86_64_args))

################################################################################
# Bootstrapping definitions
################################################################################

gcc_bstrap_config_args := $(gcc_common_args) \
                          --disable-bootstrap \
                          --disable-nls \
                          --without-system-zlib \
                          --without-zstd \
                          --with-mpc='$(bstrapdir)' \
                          --with-mpfr='$(bstrapdir)' \
                          --with-gmp='$(bstrapdir)' \
                          --with-isl='$(bstrapdir)' \
                          --enable-languages=c,c++,lto \
                          MAKEINFO='/bin/true' \
                          $(bstrap_config_flags)

$(call gen_deps,bstrap-gcc,bstrap-gmp \
                           bstrap-mpfr \
                           bstrap-mpc \
                           bstrap-isl \
                           bstrap-binutils)

config_bstrap-gcc    = $(call gcc_config_cmds,bstrap-gcc,\
                                              $(bstrapdir),\
                                              $(gcc_bstrap_config_args))
build_bstrap-gcc     = $(call gcc_build_cmds,bstrap-gcc)
clean_bstrap-gcc     = $(call gcc_clean_cmds,bstrap-gcc)
install_bstrap-gcc   = $(call gcc_install_cmds,bstrap-gcc,$(bstrapdir))
uninstall_bstrap-gcc = $(call gcc_uninstall_cmds,bstrap-gcc,$(bstrapdir))
check_bstrap-gcc     = $(call gcc_check_cmds,bstrap-gcc)

$(call gen_config_rules_with_dep,bstrap-gcc,gcc,config_bstrap-gcc)
$(call gen_clobber_rules,bstrap-gcc)
$(call gen_build_rules,bstrap-gcc,build_bstrap-gcc)
$(call gen_clean_rules,bstrap-gcc,clean_bstrap-gcc)
$(call gen_install_rules,bstrap-gcc,install_bstrap-gcc)
$(call gen_uninstall_rules,bstrap-gcc,uninstall_bstrap-gcc)
$(call gen_check_rules,bstrap-gcc,check_bstrap-gcc)
$(call gen_dir_rules,bstrap-gcc)

################################################################################
# Staging definitions
################################################################################

gcc_stage_config_args := \
	$(gcc_common_args) \
	--enable-bootstrap \
	--with-build-config="bootstrap-lto" \
	--disable-nls \
	--without-system-zlib \
	--with-zstd='$(bstrapdir)' \
	--with-mpc='$(stagedir)' \
	--with-mpfr='$(stagedir)' \
	--with-gmp='$(stagedir)' \
	--with-isl='$(stagedir)' \
	--enable-languages=c,c++,lto \
	--enable-install-libiberty \
	--enable-install-libbfd \
	--disable-werror \
	AR='$(bstrapdir)/bin/gcc-ar' \
	NM='$(bstrapdir)/bin/gcc-nm' \
	RANLIB='$(bstrapdir)/bin/gcc-ranlib' \
	OBJCOPY='$(bstrap_objcopy)' \
	OBJDUMP='$(bstrap_objdump)' \
	READELF='$(bstrap_readelf)' \
	STRIP='$(bstrap_strip)' \
	AS='$(bstrap_as)' \
	CC='$(bstrap_cc)' \
	CXX='$(bstrap_cxx)' \
	LD='$(bstrap_ld)' \
	AR_FOR_TARGET='$(bstrapdir)/bin/gcc-ar' \
	NM_FOR_TARGET='$(bstrapdir)/bin/gcc-nm' \
	RANLIB_FOR_TARGET='$(bstrapdir)/bin/gcc-ranlib' \
	OBJCOPY_FOR_TARGET='$(bstrap_objcopy)' \
	OBJDUMP_FOR_TARGET='$(bstrap_objdump)' \
	READELF_FOR_TARGET='$(bstrap_readelf)' \
	STRIP_FOR_TARGET='$(bstrap_strip)' \
	AS_FOR_TARGET='$(bstrap_as)' \
	CC_FOR_TARGET='$(bstrap_cc)' \
	CXX_FOR_TARGET='$(bstrap_cxx)' \
	LD_FOR_TARGET='$(bstrap_ld)'

gcc_stage_make_args   := \
	PATH=$(bstrapdir)/bin:$(PATH) \
	MAKEINFO='/bin/true' \
	CPPFLAGS='$(stage_cppflags)' \
	CFLAGS='$(call xclude_flags,$(lto_flags),$(stage_cflags))' \
	CXXFLAGS='$(call xclude_flags,$(lto_flags),$(stage_cxxflags))' \
	LDFLAGS='$(call xclude_flags,$(lto_flags),$(stage_ldflags))' \
	BOOT_CFLAGS='$(call xclude_flags,$(lto_flags),$(stage_cflags))' \
	BOOT_LDFLAGS='$(call xclude_flags,$(lto_flags),$(stage_ldflags))' \
	CPPFLAGS_FOR_TARGET='$(stage_cppflags)' \
	CFLAGS_FOR_TARGET='$(call xclude_flags,$(lto_flags),$(stage_cflags))' \
	CXXFLAGS_FOR_TARGET='$(call xclude_flags,$(lto_flags),$(stage_cxxflags))' \
	LDFLAGS_FOR_TARGET='$(call xclude_flags,$(lto_flags),$(stage_ldflags))'

$(call gen_deps,stage-gcc,stage-gmp \
                          stage-mpfr \
                          stage-mpc \
                          stage-isl \
                          stage-binutils \
                          bstrap-zstd)
$(call gen_check_deps,stage-gcc,stage-autogen stage-dejagnu)

config_stage-gcc    = $(call gcc_config_cmds,stage-gcc,\
                                             $(stagedir),\
                                             $(gcc_stage_config_args))
build_stage-gcc     = $(call gcc_build_cmds,stage-gcc,$(gcc_stage_make_args))
clean_stage-gcc     = $(call gcc_clean_cmds,stage-gcc)
install_stage-gcc   = $(call gcc_install_cmds,stage-gcc,\
                                              $(stagedir),\
                                              ,\
                                              $(gcc_stage_make_args))
uninstall_stage-gcc = $(call gcc_uninstall_cmds,stage-gcc,$(stagedir))
check_stage-gcc     = $(call gcc_check_cmds,stage-gcc)

$(call gen_config_rules_with_dep,stage-gcc,gcc,config_stage-gcc)
$(call gen_clobber_rules,stage-gcc)
$(call gen_build_rules,stage-gcc,build_stage-gcc)
$(call gen_clean_rules,stage-gcc,clean_stage-gcc)
$(call gen_install_rules,stage-gcc,install_stage-gcc)
$(call gen_uninstall_rules,stage-gcc,uninstall_stage-gcc)
$(call gen_check_rules,stage-gcc,check_stage-gcc)
$(call gen_dir_rules,stage-gcc)

################################################################################
# Final definitions
################################################################################

gcc_final_config_args := \
	$(gcc_common_args) \
	--enable-bootstrap \
	--with-build-config="bootstrap-lto" \
	--enable-nls \
	--with-system-zlib \
	--with-zstd='$(stagedir)' \
	--with-mpc='$(stagedir)' \
	--with-mpfr='$(stagedir)' \
	--with-gmp='$(stagedir)' \
	--with-isl='$(stagedir)' \
	--enable-languages=c,c++,lto \
	--enable-install-libiberty \
	--enable-install-libbfd \
	--disable-werror \
	AR='$(stagedir)/bin/gcc-ar' \
	NM='$(stagedir)/bin/gcc-nm' \
	RANLIB='$(stagedir)/bin/gcc-ranlib' \
	OBJCOPY='$(stage_objcopy)' \
	OBJDUMP='$(stage_objdump)' \
	READELF='$(stage_readelf)' \
	STRIP='$(stage_strip)' \
	AS='$(stage_as)' \
	CC='$(stage_cc)' \
	CXX='$(stage_cxx)' \
	LD='$(stage_ld)' \
	AR_FOR_TARGET='$(stagedir)/bin/gcc-ar' \
	NM_FOR_TARGET='$(stagedir)/bin/gcc-nm' \
	RANLIB_FOR_TARGET='$(stagedir)/bin/gcc-ranlib' \
	OBJCOPY_FOR_TARGET='$(stage_objcopy)' \
	OBJDUMP_FOR_TARGET='$(stage_objdump)' \
	READELF_FOR_TARGET='$(stage_readelf)' \
	STRIP_FOR_TARGET='$(stage_strip)' \
	AS_FOR_TARGET='$(stage_as)' \
	CC_FOR_TARGET='$(stage_cc)' \
	CXX_FOR_TARGET='$(stage_cxx)' \
	LD_FOR_TARGET='$(stage_ld)' \
	MAKEINFO='$(stage_makeinfo)'

# LD_LIBRARY_PATH:
# make all run selftest that need libisl.so.23. This lib is in ubuntu:jammy and
# debian but notin ubuntu:focal and early. Force ld library path to staging lib.
gcc_final_make_args   := \
	PATH='$(stagedir)/bin:$(PATH)' \
	LD_LIBRARY_PATH='$(stage_lib_path)' \
	CPPFLAGS='$(final_cppflags)' \
	CFLAGS='$(call xclude_flags,$(lto_flags),$(final_cflags))' \
	CXXFLAGS='$(call xclude_flags,$(lto_flags),$(final_cxxflags))' \
	LDFLAGS='$(call xclude_flags,$(lto_flags),$(final_ldflags))' \
	BOOT_CFLAGS='$(call xclude_flags,$(lto_flags),$(final_cflags))' \
	BOOT_LDFLAGS='$(call xclude_flags,$(lto_flags),$(final_ldflags))' \
	CPPFLAGS_FOR_TARGET='$(final_cppflags)' \
	CFLAGS_FOR_TARGET='$(call xclude_flags,$(lto_flags),$(final_cflags))' \
	CXXFLAGS_FOR_TARGET='$(call xclude_flags,$(lto_flags),$(final_cxxflags))' \
	LDFLAGS_FOR_TARGET='$(call xclude_flags,$(lto_flags),$(final_ldflags))'

$(call gen_deps,final-gcc,stage-gmp \
                          stage-mpfr \
                          stage-mpc \
                          stage-isl \
                          stage-binutils \
                          stage-zstd \
                          stage-zlib \
                          stage-gettext \
                          stage-texinfo)
$(call gen_check_deps,final-gcc,stage-autogen stage-dejagnu)

config_final-gcc    = $(call gcc_config_cmds,final-gcc,\
                                             $(PREFIX),\
                                             $(gcc_final_config_args))
build_final-gcc     = $(call gcc_build_cmds,final-gcc,$(gcc_final_make_args))
clean_final-gcc     = $(call gcc_clean_cmds,final-gcc)
install_final-gcc   = $(call gcc_install_cmds,final-gcc,\
                                              $(PREFIX),\
                                              $(finaldir),\
                                              $(gcc_final_make_args))
uninstall_final-gcc = $(call gcc_uninstall_cmds,final-gcc,\
                                                $(PREFIX),\
                                                $(finaldir))
check_final-gcc     = $(call gcc_check_cmds,final-gcc,\
                             LD_LIBRARY_PATH='$(stage_lib_path)')

$(call gen_config_rules_with_dep,final-gcc,gcc,config_final-gcc)
$(call gen_clobber_rules,final-gcc)
$(call gen_build_rules,final-gcc,build_final-gcc)
$(call gen_clean_rules,final-gcc,clean_final-gcc)
$(call gen_install_rules,final-gcc,install_final-gcc)
$(call gen_uninstall_rules,final-gcc,uninstall_final-gcc)
$(call gen_check_rules,final-gcc,check_final-gcc)
$(call gen_dir_rules,final-gcc)
