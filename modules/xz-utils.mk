################################################################################
# xz-utils modules
################################################################################

xz-utils_dist_url  := https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz
xz-utils_dist_sum  := 151b2a47fdf00274c4fd71ceada8fb6c892bdac44070847ebf3259e602b97c95ee5ee88974e03d7aa821ab4f16d5c38e50dfb2baf660cf39c199878a666e19ad
xz-utils_dist_name := $(subst xz-,xz-utils-,$(notdir $(xz-utils_dist_url)))
xz-utils_vers      := $(patsubst xz-utils-%.tar.xz,%,$(xz-utils_dist_name))
xz-utils_brief     := XZ-format compression library
xz-utils_home      := https://tukaani.org/xz/

define xz-utils_desc
XZ is the successor to the Lempel-Ziv/Markov-chain Algorithm compression format,
which provides memory-hungry but powerful compression (often better than bzip2)
and fast, easy decompression.

This package provides the command line tools for working with XZ compression,
including ``xz``, ``unxz``, ``xzcat``, ``xzgrep``, and so on. They can also
handle the older LZMA format, and if invoked via appropriate symlinks will
emulate the behavior of the commands in the lzma package.

The XZ format is similar to the older LZMA format but includes some improvements
for general use:

* ``file`` magic for detecting XZ files;
* crc64 data integrity check;
* limited random-access reading support;
* improved support for multithreading;
* support for flushing the encoder.
endef

define fetch_xz-utils_dist
$(call download_csum,$(xz-utils_dist_url),\
                     $(xz-utils_dist_name),\
                     $(xz-utils_dist_sum))
endef
$(call gen_fetch_rules,xz-utils,xz-utils_dist_name,fetch_xz-utils_dist)

define xtract_xz-utils
$(call rmrf,$(srcdir)/xz-utils)
$(call untar,$(srcdir)/xz-utils,\
             $(FETCHDIR)/$(xz-utils_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,xz-utils,xtract_xz-utils)

$(call gen_dir_rules,xz-utils)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define xz-utils_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/xz-utils/configure --prefix="$(strip $(2))" $(3) $(verbose)
endef

# $(1): targets base name / module name
define xz-utils_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define xz-utils_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define xz-utils_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define xz-utils_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define xz-utils_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

xz-utils_common_args := --enable-silent-rules \
                        --disable-debug \
                        --enable-threads=yes \
                        --enable-static

################################################################################
# Bootstrapping definitions
################################################################################

xz-utils_bstrap_config_args := \
	$(xz-utils_common_args) \
	--disable-nls \
	--disable-doc \
	--disable-shared \
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
	CPPFLAGS='$(bstrap_cppflags)' \
	CFLAGS='$(bstrap_cflags)' \
	CXXFLAGS='$(bstrap_cxxflags)' \
	LDFLAGS='$(bstrap_ldflags)'

$(call gen_deps,bstrap-xz-utils,bstrap-gcc)

config_bstrap-xz-utils       = $(call xz-utils_config_cmds,\
                                      bstrap-xz-utils,\
                                      $(bstrapdir),\
                                      $(xz-utils_bstrap_config_args))
build_bstrap-xz-utils        = $(call xz-utils_build_cmds,bstrap-xz-utils)
clean_bstrap-xz-utils        = $(call xz-utils_clean_cmds,bstrap-xz-utils)
install_bstrap-xz-utils      = $(call xz-utils_install_cmds,bstrap-xz-utils)
uninstall_bstrap-xz-utils    = $(call xz-utils_uninstall_cmds,\
                                      bstrap-xz-utils,\
                                      $(bstrapdir))
check_bstrap-xz-utils        = $(call xz-utils_check_cmds,bstrap-xz-utils)

$(call gen_config_rules_with_dep,bstrap-xz-utils,\
                                 xz-utils,\
                                 config_bstrap-xz-utils)
$(call gen_clobber_rules,bstrap-xz-utils)
$(call gen_build_rules,bstrap-xz-utils,build_bstrap-xz-utils)
$(call gen_clean_rules,bstrap-xz-utils,clean_bstrap-xz-utils)
$(call gen_install_rules,bstrap-xz-utils,install_bstrap-xz-utils)
$(call gen_uninstall_rules,bstrap-xz-utils,uninstall_bstrap-xz-utils)
$(call gen_check_rules,bstrap-xz-utils,check_bstrap-xz-utils)
$(call gen_dir_rules,bstrap-xz-utils)

################################################################################
# Staging definitions
################################################################################

xz-utils_stage_config_args := \
	$(xz-utils_common_args) \
	--disable-nls \
	--disable-doc \
	--enable-shared \
	AR='$(stage_ar)' \
	NM='$(stage_nm)' \
	RANLIB='$(stage_ranlib)' \
	OBJCOPY='$(stage_objcopy)' \
	OBJDUMP='$(stage_objdump)' \
	READELF='$(stage_readelf)' \
	STRIP='$(stage_strip)' \
	AS='$(stage_as)' \
	CC='$(stage_cc)' \
	CXX='$(stage_cxx)' \
	CPPFLAGS='$(stage_cppflags)' \
	CFLAGS='$(stage_cflags)' \
	CXXFLAGS='$(stage_cxxflags)' \
	LDFLAGS='$(call xclude_flags,$(rpath_flags),$(stage_ldflags))'

$(call gen_deps,stage-xz-utils,stage-gcc)

config_stage-xz-utils       = $(call xz-utils_config_cmds,\
                                     stage-xz-utils,\
                                     $(stagedir),\
                                     $(xz-utils_stage_config_args))
build_stage-xz-utils        = $(call xz-utils_build_cmds,stage-xz-utils)
clean_stage-xz-utils        = $(call xz-utils_clean_cmds,stage-xz-utils)
install_stage-xz-utils      = $(call xz-utils_install_cmds,stage-xz-utils)
uninstall_stage-xz-utils    = $(call xz-utils_uninstall_cmds,\
                                     stage-xz-utils,\
                                     $(stagedir))
check_stage-xz-utils        = $(call xz-utils_check_cmds,stage-xz-utils)

$(call gen_config_rules_with_dep,stage-xz-utils,xz-utils,config_stage-xz-utils)
$(call gen_clobber_rules,stage-xz-utils)
$(call gen_build_rules,stage-xz-utils,build_stage-xz-utils)
$(call gen_clean_rules,stage-xz-utils,clean_stage-xz-utils)
$(call gen_install_rules,stage-xz-utils,install_stage-xz-utils)
$(call gen_uninstall_rules,stage-xz-utils,uninstall_stage-xz-utils)
$(call gen_check_rules,stage-xz-utils,check_stage-xz-utils)
$(call gen_dir_rules,stage-xz-utils)

################################################################################
# Final definitions
################################################################################

xz-utils_final_config_args := $(xz-utils_common_args) \
                              --enable-nls \
                              --enable-doc \
                              --enable-shared \
                              --with-sysroot='$(stagedir)' \
                              $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-xz-utils,stage-gettext stage-texinfo)

config_final-xz-utils       = $(call xz-utils_config_cmds,\
                                     final-xz-utils,\
                                     $(PREFIX),\
                                     $(xz-utils_final_config_args))
build_final-xz-utils        = $(call xz-utils_build_cmds,final-xz-utils)
clean_final-xz-utils        = $(call xz-utils_clean_cmds,final-xz-utils)
install_final-xz-utils      = $(call xz-utils_install_cmds,\
                                     final-xz-utils,\
                                     $(finaldir))
uninstall_final-xz-utils    = $(call xz-utils_uninstall_cmds,\
                                     final-xz-utils,\
                                     $(PREFIX),\
                                     $(finaldir))
check_final-xz-utils        = $(call xz-utils_check_cmds,final-xz-utils)

$(call gen_config_rules_with_dep,final-xz-utils,xz-utils,config_final-xz-utils)
$(call gen_clobber_rules,final-xz-utils)
$(call gen_build_rules,final-xz-utils,build_final-xz-utils)
$(call gen_clean_rules,final-xz-utils,clean_final-xz-utils)
$(call gen_install_rules,final-xz-utils,install_final-xz-utils)
$(call gen_uninstall_rules,final-xz-utils,uninstall_final-xz-utils)
$(call gen_check_rules,final-xz-utils,check_final-xz-utils)
$(call gen_dir_rules,final-xz-utils)
