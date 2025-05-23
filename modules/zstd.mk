################################################################################
# zstd modules
################################################################################

zstd_dist_url  := https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
zstd_dist_sum  := b4de208f179b68d4c6454139ca60d66ed3ef3893a560d6159a056640f83d3ee67cdf6ffb88971cdba35449dba4b597eaa8b4ae908127ef7fd58c89f40bf9a705
zstd_dist_name := $(notdir $(zstd_dist_url))
zstd_vers      := $(patsubst zstd-%.tar.gz,%,$(zstd_dist_name))
zstd_brief     := Fast lossless compression algorithm
zstd_home      := https://github.com/facebook/zstd

define zstd_desc
Zstd, short for Zstandard, is a fast lossless compression algorithm, targeting
real-time compression scenarios at zlib-level compression ratio.
endef

define fetch_zstd_dist
$(call download_csum,$(zstd_dist_url),\
                     $(zstd_dist_name),\
                     $(zstd_dist_sum))
endef
$(call gen_fetch_rules,zstd,zstd_dist_name,fetch_zstd_dist)

define xtract_zstd
$(call rmrf,$(srcdir)/zstd)
$(call untar,$(srcdir)/zstd,\
             $(FETCHDIR)/$(zstd_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,zstd,xtract_zstd)

$(call gen_dir_rules,zstd)

# $(1): targets base name / module name
define zstd_config_cmds
$(RSYNC) --archive --delete $(srcdir)/zstd/ $(builddir)/$(strip $(1))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): shared library compile and link flags
# $(4): static library compile and link flags
# $(5): binary compile and link flags
define zstd_build_cmds
$(if $(strip $(3)),\
     +$(MAKE) --directory $(builddir)/$(strip $(1))/lib \
              libzstd-release \
              BUILD_DIR='$(builddir)/$(strip $(1))/lib/build' \
              PREFIX='$(strip $(2))' \
              prefix='$(strip $(2))' \
              $(3) \
              $(verbose))
$(if $(strip $(4)),\
     +$(MAKE) --directory $(builddir)/$(strip $(1))/lib \
              libzstd.a \
              BUILD_DIR='$(builddir)/$(strip $(1))/lib/build' \
              PREFIX='$(strip $(2))' \
              prefix='$(strip $(2))' \
              $(4) \
              $(verbose))
$(if $(strip $(5)),\
     +$(MAKE) --directory $(builddir)/$(strip $(1))/programs \
              zstd-release \
              BUILD_DIR='$(builddir)/$(strip $(1))/programs/build' \
              PREFIX='$(strip $(2))' \
              prefix='$(strip $(2))' \
              $(5) \
              $(verbose))
endef

# $(1): targets base name / module name
define zstd_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/lib clean $(verbose)
$(call rmrf,$(builddir)/$(strip $(1))/lib/build)
+$(MAKE) --directory $(builddir)/$(strip $(1))/programs clean $(verbose)
$(call rmrf,$(builddir)/$(strip $(1))/programs/build)
+$(MAKE) --directory $(builddir)/$(strip $(1))/tests clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): common compile and link flags
# $(4): optional install destination directory
define zstd_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/lib \
         install \
         PREFIX='$(strip $(2))' \
         prefix='$(strip $(2))' \
         $(3) \
         $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
         $(verbose)
+$(MAKE) --directory $(builddir)/$(strip $(1))/programs \
         install \
         PREFIX='$(strip $(2))' \
         prefix='$(strip $(2))' \
         $(3) \
         $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): common compile and link flags
# $(4): optional install destination directory
define zstd_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1))/lib \
          uninstall \
          PREFIX='$(strip $(2))' \
          prefix='$(strip $(2))' \
          $(3) \
          $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
          $(verbose)
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1))/programs \
          uninstall \
          PREFIX='$(strip $(2))' \
          prefix='$(strip $(2))' \
          $(3) \
          $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(4))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): binary compile and link flags
#
# Run zstd tests passing the build directory used into zstd_build_cmds() macro
# above to ensure we test binaries that will be installed instead of testing
# binaries built with instrumentation options enabled.
define zstd_check_cmds
+env LD_LIBRARY_PATH='$(builddir)/$(strip $(1))/lib' \
$(MAKE) -j1 \
        --directory $(builddir)/$(strip $(1))/tests \
        test \
        PREFIX='$(strip $(2))' \
        prefix='$(strip $(2))' \
        BUILD_DIR='$(builddir)/$(strip $(1))/programs/build' \
        $(3)
endef

################################################################################
# Bootstrapping definitions
################################################################################

zstd_bstrap_make_args := AR='$(bstrap_ar)' \
                         NM='$(bstrap_nm)' \
                         RANLIB='$(bstrap_ranlib)' \
                         CC='$(bstrap_cc)' \
                         CXX='$(bstrap_cxx)'

zstd_bstrap_statlib_make_args := \
	$(zstd_bstrap_make_args) \
	CPPFLAGS_STATLIB='$(bstrap_cppflags) -DZSTD_MULTITHREAD' \
	CFLAGS='$(call xclude_flags,$(o_flags),\
	                            $(bstrap_cflags)) -O3 -fvisibility=hidden'

zstd_bstrap_bin_make_args     := \
	$(zstd_bstrap_make_args) \
	CFLAGS='$(call xclude_flags,$(o_flags),$(bstrap_cflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags),$(bstrap_ldflags)) -O3 -pthread'

$(call gen_deps,bstrap-zstd,bstrap-xz-utils bstrap-lz4)

config_bstrap-zstd    = $(call zstd_config_cmds,bstrap-zstd)
build_bstrap-zstd     = $(call zstd_build_cmds,\
                               bstrap-zstd,\
                               $(bstrapdir),\
                               ,\
                               $(zstd_bstrap_statlib_make_args),\
                               $(zstd_bstrap_bin_make_args))
clean_bstrap-zstd     = $(call zstd_clean_cmds,bstrap-zstd)
install_bstrap-zstd   = $(call zstd_install_cmds,bstrap-zstd,\
                                                 $(bstrapdir),\
                                                 $(zstd_bstrap_make_args))
uninstall_bstrap-zstd = $(call zstd_uninstall_cmds,bstrap-zstd,\
                                                   $(bstrapdir),\
                                                   $(zstd_bstrap_make_args))
check_bstrap-zstd     = $(call zstd_check_cmds,bstrap-zstd,\
                                               $(bstrapdir),\
                                               $(zstd_bstrap_bin_make_args))

$(call gen_config_rules_with_dep,bstrap-zstd,zstd,config_bstrap-zstd)
$(call gen_clobber_rules,bstrap-zstd)
$(call gen_build_rules,bstrap-zstd,build_bstrap-zstd)
$(call gen_clean_rules,bstrap-zstd,clean_bstrap-zstd)
$(call gen_install_rules,bstrap-zstd,install_bstrap-zstd)
$(call gen_uninstall_rules,bstrap-zstd,uninstall_bstrap-zstd)
$(call gen_check_rules,bstrap-zstd,check_bstrap-zstd)
$(call gen_dir_rules,bstrap-zstd)

################################################################################
# Staging definitions
################################################################################

zstd_stage_make_args         := AR='$(stage_ar)' \
                                NM='$(stage_nm)' \
                                RANLIB='$(stage_ranlib)' \
                                CC='$(stage_cc)' \
                                CXX='$(stage_cxx)'

zstd_stage_shlib_make_args   := \
	$(zstd_stage_make_args) \
	CPPFLAGS_DYNLIB='$(stage_cppflags) -DZSTD_MULTITHREAD' \
	CFLAGS='$(call xclude_flags,\
	               $(o_flags),\
	               $(stage_cflags)) -O3 -fPIC -fvisibility=hidden' \
	LDFLAGS_DYNLIB='$(call xclude_flags,\
	                       $(o_flags) $(rpath_flags),\
	                       $(stage_ldflags)) -fPIC -O3 -pthread'

zstd_stage_statlib_make_args := \
	$(zstd_stage_make_args) \
	CPPFLAGS_STATLIB='$(stage_cppflags) -DZSTD_MULTITHREAD' \
	CFLAGS='$(call xclude_flags,$(o_flags),\
	                            $(stage_cflags)) -O3 -fvisibility=hidden'

zstd_stage_bin_make_args     := \
	$(zstd_stage_make_args) \
	CFLAGS='$(call xclude_flags,$(o_flags),$(stage_cflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags),$(stage_ldflags)) -O3 -pthread'

$(call gen_deps,stage-zstd,stage-zlib stage-xz-utils stage-lz4)

config_stage-zstd    = $(call zstd_config_cmds,stage-zstd)
build_stage-zstd     = $(call zstd_build_cmds,stage-zstd,\
                                              $(stagedir),\
                                              $(zstd_stage_shlib_make_args),\
                                              $(zstd_stage_statlib_make_args),\
                                              $(zstd_stage_bin_make_args))
clean_stage-zstd     = $(call zstd_clean_cmds,stage-zstd)
install_stage-zstd   = $(call zstd_install_cmds,stage-zstd,\
                                                $(stagedir),\
                                                $(zstd_stage_make_args))
uninstall_stage-zstd = $(call zstd_uninstall_cmds,stage-zstd,\
                                                  $(stagedir),\
                                                  $(zstd_stage_make_args))
check_stage-zstd     = $(call zstd_check_cmds,stage-zstd,\
                                              $(stagedir),\
                                              $(zstd_stage_bin_make_args))

$(call gen_config_rules_with_dep,stage-zstd,zstd,config_stage-zstd)
$(call gen_clobber_rules,stage-zstd)
$(call gen_build_rules,stage-zstd,build_stage-zstd)
$(call gen_clean_rules,stage-zstd,clean_stage-zstd)
$(call gen_install_rules,stage-zstd,install_stage-zstd)
$(call gen_uninstall_rules,stage-zstd,uninstall_stage-zstd)
$(call gen_check_rules,stage-zstd,check_stage-zstd)
$(call gen_dir_rules,stage-zstd)

################################################################################
# Final definitions
################################################################################

zstd_final_make_args         := AR='$(stage_ar)' \
                                NM='$(stage_nm)' \
                                RANLIB='$(stage_ranlib)' \
                                CC='$(stage_cc)' \
                                CXX='$(stage_cxx)'

zstd_final_shlib_make_args   := \
	$(zstd_final_make_args) \
	CPPFLAGS_DYNLIB='$(final_cppflags) -DZSTD_MULTITHREAD' \
	CFLAGS='$(call xclude_flags,\
	               $(o_flags),\
	               $(final_cflags)) -O3 -fPIC -fvisibility=hidden' \
	LDFLAGS_DYNLIB='$(call xclude_flags,\
	                       $(o_flags) $(rpath_flags),\
	                       $(final_ldflags)) -fPIC -O3 -pthread'

zstd_final_statlib_make_args := \
	$(zstd_final_make_args) \
	CPPFLAGS_STATLIB='$(final_cppflags) -DZSTD_MULTITHREAD' \
	CFLAGS='$(call xclude_flags,$(o_flags),\
	                            $(final_cflags)) -O3 -fvisibility=hidden'

zstd_final_bin_make_args     := \
	$(zstd_final_make_args) \
	CFLAGS='$(call xclude_flags,$(o_flags),$(final_cflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags),\
	                             $(final_ldflags)) -O3 -pthread'

$(call gen_deps,final-zstd,stage-zlib stage-xz-utils stage-lz4)
$(call gen_check_deps,final-zstd,stage-gcc)

config_final-zstd    = $(call zstd_config_cmds,final-zstd)
build_final-zstd     = $(call zstd_build_cmds,final-zstd,\
                                              $(PREFIX),\
                                              $(zstd_final_shlib_make_args),\
                                              $(zstd_final_statlib_make_args),\
                                              $(zstd_final_bin_make_args))
clean_final-zstd     = $(call zstd_clean_cmds,final-zstd)
install_final-zstd   = $(call zstd_install_cmds,final-zstd,\
                                                $(PREFIX),\
                                                $(zstd_final_make_args),\
                                                $(finaldir))
uninstall_final-zstd = $(call zstd_uninstall_cmds,final-zstd,\
                                                  $(PREFIX),\
                                                  $(zstd_final_make_args),\
                                                  $(finaldir))
check_final-zstd     = $(call zstd_check_cmds,final-zstd,\
                                              $(PREFIX),\
                                              $(zstd_final_bin_make_args))

$(call gen_config_rules_with_dep,final-zstd,zstd,config_final-zstd)
$(call gen_clobber_rules,final-zstd)
$(call gen_build_rules,final-zstd,build_final-zstd)
$(call gen_clean_rules,final-zstd,clean_final-zstd)
$(call gen_install_rules,final-zstd,install_final-zstd)
$(call gen_uninstall_rules,final-zstd,uninstall_final-zstd)
$(call gen_check_rules,final-zstd,check_final-zstd)
$(call gen_dir_rules,final-zstd)
