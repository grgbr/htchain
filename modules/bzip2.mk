################################################################################
# bzip2 modules
################################################################################

bzip2_dist_url   := https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
bzip2_dist_sum   := 083f5e675d73f3233c7930ebe20425a533feedeaaa9d8cc86831312a6581cefbe6ed0d08d2fa89be81082f2a5abdabca8b3c080bf97218a1bd59dc118a30b9f3
bzip2_dist_name  := $(notdir $(bzip2_dist_url))
bzip2_vers       := $(patsubst bzip2-%.tar.gz,%,$(bzip2_dist_name))
_bzip2_vers_toks := $(subst .,$(space),$(bzip2_vers))
bzip2_vers_maj   := $(word 1,$(_bzip2_vers_toks))
bzip2_vers_min   := $(word 2,$(_bzip2_vers_toks))
bzip2_brief      := High-quality block-sorting file compressor
bzip2_home       := https://sourceware.org/bzip2/

define bzip2_desc
bzip2 is a freely available, patent free, data compressor.

bzip2 compresses files using the Burrows-Wheeler block-sorting text compression
algorithm, and Huffman coding.  Compression is generally considerably better
than that achieved by more conventional LZ77/LZ78-based compressors, and
approaches the performance of the PPM family of statistical compressors.

The archive file format of bzip2 (.bz2) is incompatible with that of its
predecessor, bzip (.bz).
endef

define fetch_bzip2_dist
$(call download_csum,$(bzip2_dist_url),\
                     $(bzip2_dist_name),\
                     $(bzip2_dist_sum))
endef
$(call gen_fetch_rules,bzip2,bzip2_dist_name,fetch_bzip2_dist)

define xtract_bzip2
$(call rmrf,$(srcdir)/bzip2)
$(call untar,$(srcdir)/bzip2,\
             $(FETCHDIR)/$(bzip2_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,bzip2,xtract_bzip2)

$(call gen_dir_rules,bzip2)

# $(1): targets base name / module name
define bzip2_config_cmds
$(call mkdir,$(builddir)/$(1)/static)
$(RSYNC) --archive --delete $(srcdir)/bzip2/ $(builddir)/$(1)/static
$(call mkdir,$(builddir)/$(1)/shared)
$(RSYNC) --archive --delete $(srcdir)/bzip2/ $(builddir)/$(1)/shared
endef

bzip2_intern_cflags := -Wall -Winline -D_FILE_OFFSET_BITS=64

# $(1): targets base name / module name
# $(2): build /install prefix
# $(3): static library and binary build flags
# $(4): shared binary build flags
# $(5): shared library build flags
define bzip2_build_cmds
+$(MAKE) --directory $(builddir)/$(1)/static $(3) $(verbose)
+$(MAKE) --directory $(builddir)/$(1)/shared $(4) $(verbose)
+$(MAKE) --directory $(builddir)/$(1)/shared \
         --makefile $(builddir)/$(1)/shared/Makefile-libbz2_so \
         $(5) \
         $(verbose)
endef

# $(1): targets base name / module name
define clean_bzip2
+$(MAKE) --directory $(builddir)/$(1)/static clean
+$(MAKE) --directory $(builddir)/$(1)/shared clean
endef

# $(1): targets base name / module name
# $(2): build /install prefix
# $(3): optional install destination directory
define bzip2_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/static \
         install \
         PREFIX='$(strip $(3))$(strip $(2))'
$(INSTALL) -m755 --directory $(strip $(3))$(strip $(2))/share/man/man1
$(MV) $(strip $(3))$(strip $(2))/man/man1/* \
      $(strip $(3))$(strip $(2))/share/man/man1/
$(call rmrf,$(strip $(3))$(strip $(2))/man)
$(INSTALL) -m755 --directory $(strip $(3))$(strip $(2))/lib
$(INSTALL) -m755 $(builddir)/$(strip $(1))/shared/libbz2.so.$(bzip2_vers) \
                 $(strip $(3))$(strip $(2))/lib/libbz2.so.$(bzip2_vers)
$(call slink,\
       libbz2.so.$(bzip2_vers),\
       $(strip $(3))$(strip $(2))/lib/libbz2.so)
$(call slink,\
       libbz2.so.$(bzip2_vers),\
       $(strip $(3))$(strip $(2))/lib/libbz2.so.$(bzip2_vers_maj).$(bzip2_vers_min))
$(call slink,bzgrep,$(strip $(3))$(strip $(2))/bin/bzegrep)
$(call slink,bzgrep,$(strip $(3))$(strip $(2))/bin/bzfgrep)
$(call slink,bzmore,$(strip $(3))$(strip $(2))/bin/bzless)
$(call slink,bzdiff,$(strip $(3))$(strip $(2))/bin/bzcmp)
$(call hlink,$(strip $(3))$(strip $(2))/bin/bzip2,\
             $(strip $(3))$(strip $(2))/bin/bunzip2)
$(call hlink,$(strip $(3))$(strip $(2))/bin/bzip2,\
             $(strip $(3))$(strip $(2))/bin/bzcat)
endef

# $(1): build /install prefix
# $(2): optional install destination directory
define bzip2_uninstall_cmds
$(foreach b,\
          bzegrep bzless bzmore bzcmp bzdiff bzgrep bzip2 bzcat bzip2recover \
          bzfgrep bunzip2,\
          $(call rmf,$(strip $(2))$(strip $(1))/bin/$(b))$(newline))
$(call rmf,$(strip $(2))$(strip $(1))/include/bzlib.h)
$(foreach l,\
          libbz2.a \
          libbz2.so \
          libbz2.so.$(bzip2_vers) \
          libbz2.so.$(bzip2_vers_maj).$(bzip2_vers_min),\
          $(call rmf,$(strip $(2))$(strip $(1))/lib/$(l))$(newline))
$(foreach m,\
          bzegrep bzless bzmore bzcmp bzdiff bzgrep bzip2 bzfgrep,\
          $(call rmf,$(strip $(2))$(strip $(1))/man/man1/$(m).1)$(newline))
$(foreach m,\
          bzegrep bzless bzmore bzcmp bzdiff bzgrep bzip2 bzfgrep,\
          $(call rmf,$(strip $(2))$(strip $(1))/share/man/man1/$(m).1)$(newline))
$(call cleanup_empty_dirs,$(strip $(2))$(strip $(1)))
endef

# $(1): targets base name / module name
define bzip2_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/static check
$(call slink,bzip2-shared,$(builddir)/$(strip $(1))/shared/bzip2)
+env LD_LIBRARY_PATH='$(builddir)/$(strip $(1))/shared' \
$(MAKE) --directory $(builddir)/$(strip $(1))/shared check
endef

################################################################################
# Staging definitions
################################################################################

bzip2_stage_static_flags := \
	AR='$(bstrap_ar)' \
	RANLIB='$(bstrap_ranlib)' \
	CC='$(bstrap_cc)' \
	CFLAGS='$(stage_cflags) $(bzip2_intern_cflags)' \
	LDFLAGS='$(stage_ldflags) $(bzip2_intern_cflags)' \
	LD_LIBRARY_PATH='$(bstrap_lib_path)'

bzip2_stage_shared_flags := \
	AR='$(bstrap_ar)' \
	RANLIB='$(bstrap_ranlib)' \
	CC='$(bstrap_cc)' \
	CFLAGS='$(stage_cflags) -fPIC $(bzip2_intern_cflags)' \
	LDFLAGS='$(stage_ldflags) -fPIC $(bzip2_intern_cflags)' \
	LD_LIBRARY_PATH='$(bstrap_lib_path)'

bzip2_stage_shlib_flags := \
	AR='$(bstrap_ar)' \
	RANLIB='$(bstrap_ranlib)' \
	CC='$(bstrap_cc) $(stage_ldflags)' \
	CFLAGS='$(stage_cflags) -fPIC $(bzip2_intern_cflags)' \
	LD_LIBRARY_PATH='$(bstrap_lib_path)'

$(call gen_deps,stage-bzip2,stage-gcc)

config_stage-bzip2     = $(call bzip2_config_cmds,stage-bzip2)
build_stage-bzip2      = $(call bzip2_build_cmds,stage-bzip2,\
                                                 $(stagedir),\
                                                 $(bzip2_stage_static_flags),\
                                                 $(bzip2_stage_shared_flags),\
                                                 $(bzip2_stage_shlib_flags))
clean_stage-bzip2      = $(call bzip2_clean_cmds,stage-bzip2)
install_stage-bzip2    = $(call bzip2_install_cmds,stage-bzip2,$(stagedir))
uninstall_stage-bzip2  = $(call bzip2_uninstall_cmds,$(stagedir))
check_stage-bzip2      = $(call bzip2_check_cmds,stage-bzip2)

$(call gen_config_rules_with_dep,stage-bzip2,bzip2,config_stage-bzip2)
$(call gen_clobber_rules,stage-bzip2)
$(call gen_build_rules,stage-bzip2,build_stage-bzip2)
$(call gen_clean_rules,stage-bzip2,clean_stage-bzip2)
$(call gen_install_rules,stage-bzip2,install_stage-bzip2)
$(call gen_uninstall_rules,stage-bzip2,uninstall_stage-bzip2)
$(call gen_check_rules,stage-bzip2,check_stage-bzip2)
$(call gen_dir_rules,stage-bzip2)

################################################################################
# Final definitions
################################################################################

bzip2_final_static_flags := \
	AR='$(stage_ar)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc)' \
	CFLAGS='$(final_cflags) $(bzip2_intern_cflags)' \
	LDFLAGS='$(final_ldflags) $(bzip2_intern_cflags)' \
	LD_LIBRARY_PATH='$(stage_lib_path)'

bzip2_final_shared_flags := \
	AR='$(stage_ar)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc)' \
	CFLAGS='$(final_cflags) -fPIC $(bzip2_intern_cflags)' \
	LDFLAGS='$(final_ldflags) -fPIC $(bzip2_intern_cflags)' \
	LD_LIBRARY_PATH='$(stage_lib_path)'

bzip2_final_shlib_flags := \
	AR='$(stage_ar)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc) $(final_ldflags)' \
	CFLAGS='$(final_cflags) -fPIC $(bzip2_intern_cflags)' \
	LD_LIBRARY_PATH='$(stage_lib_path)'

$(call gen_deps,final-bzip2,stage-gcc)

config_final-bzip2     = $(call bzip2_config_cmds,final-bzip2)
build_final-bzip2      = $(call bzip2_build_cmds,final-bzip2,\
                                                 $(PREFIX),\
                                                 $(bzip2_final_static_flags),\
                                                 $(bzip2_final_shared_flags),\
                                                 $(bzip2_final_shlib_flags))
clean_final-bzip2      = $(call bzip2_clean_cmds,final-bzip2)
install_final-bzip2    = $(call bzip2_install_cmds,final-bzip2,\
                                                   $(PREFIX),\
                                                   $(finaldir))
uninstall_final-bzip2  = $(call bzip2_uninstall_cmds,$(PREFIX),$(finaldir))
check_final-bzip2      = $(call bzip2_check_cmds,final-bzip2)

$(call gen_config_rules_with_dep,final-bzip2,bzip2,config_final-bzip2)
$(call gen_clobber_rules,final-bzip2)
$(call gen_build_rules,final-bzip2,build_final-bzip2)
$(call gen_clean_rules,final-bzip2,clean_final-bzip2)
$(call gen_install_rules,final-bzip2,install_final-bzip2)
$(call gen_uninstall_rules,final-bzip2,uninstall_final-bzip2)
$(call gen_check_rules,final-bzip2,check_final-bzip2)
$(call gen_dir_rules,final-bzip2)
