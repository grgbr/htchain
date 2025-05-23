################################################################################
# ncurses modules
#
# AFAIK, there is no automatic unit testing logic provided with ncurses.
#
# TODO: libtinfo.so.6: version `NCURSES6_TINFO_6.2.current' not found
#       (required by bash)
################################################################################

ncurses_dist_url  := https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz
ncurses_dist_sum  := fc5a13409d2a530a1325776dcce3a99127ddc2c03999cfeb0065d0eee2d68456274fb1c7b3cc99c1937bc657d0e7fca97016e147f93c7821b5a4a6837db821e8
ncurses_dist_name := $(notdir $(ncurses_dist_url))
ncurses_vers      := $(patsubst ncurses-%.tar.gz,%,$(ncurses_dist_name))
ncurses_brief     := Terminal-independent handling of character screens
ncurses_home      := https://invisible-island.net/ncurses/ncurses.html

define ncurses_desc
The ncurses (new curses) library is a free software emulation of curses in
System V Release 4.0 (SVr4), and more. It uses terminfo format, supports pads
and color and multiple highlights and forms characters and function-key mapping,
and has all the other SVr4-curses enhancements over BSD curses. SVr4 curses
became the basis of X/Open Curses.
endef

define fetch_ncurses_dist
$(call download_csum,$(ncurses_dist_url),\
                     $(ncurses_dist_name),\
                     $(ncurses_dist_sum))
endef
$(call gen_fetch_rules,ncurses,ncurses_dist_name,fetch_ncurses_dist)

urxvt_tinfo_dist_url  := https://raw.githubusercontent.com/exg/rxvt-unicode/rxvt-unicode-9.30/doc/etc/rxvt-unicode.terminfo
urxvt_tinfo_dist_sum  := 325d65f4fd84e10ef4ebf8b06a003d4afe4ded2e5ec36d7c49d6c17107d851950a8d9373d1238d67b5083512ba934dc332c34d640303bda45ae3b2291f4174b8
urxvt_tinfo_dist_name := $(notdir $(urxvt_tinfo_dist_url))

define fetch_urxvt_tinfo_dist
$(call download_csum,$(urxvt_tinfo_dist_url),\
                     $(urxvt_tinfo_dist_name),\
                     $(urxvt_tinfo_dist_sum))
endef
$(call gen_fetch_rules,ncurses,urxvt_tinfo_dist_name,fetch_urxvt_tinfo_dist)

define xtract_ncurses
$(call rmrf,$(srcdir)/ncurses)
$(call untar,$(srcdir)/ncurses,\
             $(FETCHDIR)/$(ncurses_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,ncurses,xtract_ncurses)

$(call gen_dir_rules,ncurses)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define ncurses_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/ncurses/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define ncurses_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define ncurses_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define ncurses_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(stagedir)/bin/tic -o $(strip $(3))$(strip $(2))/share/terminfo \
                    $(FETCHDIR)/$(urxvt_tinfo_dist_name) \
                    $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define ncurses_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call rmf,$(strip $(3))$(strip $(2))/lib/terminfo)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# --with-versioned-syms is required for Debian interoperability
ncurses_common_config_args := \
	--enable-silent-rules \
	--enable-overwrite \
	--disable-lib_suffixes \
	--without-ada \
	--without-gpm \
	--with-pkg-config \
	--enable-pc-files \
	--with-shared \
	--with-cxx-shared \
	--with-versioned-syms=yes \
	--with-termlib=tinfo \
	--with-ticlib=tic \
	--disable-termcap \
	--enable-symlinks \
	--disable-root-environ \
	--disable-root-access \
	--enable-sp-funcs \
	--enable-const \
	--enable-ext-colors \
	--enable-ext-putwin \
	--enable-sigwinch \
	--enable-tcap-names \
	--enable-widec \
	--enable-wattr-macros \
	--enable-getcap \
	--enable-getcap-cache \
	--disable-rpath \
	--disable-relink \
	--without-tests

################################################################################
# Staging definitions
#
# Build with libtool dependency at staging time since required to properly build
# with symbol versioning which is requested by system-wide bash.
################################################################################

# As of version 6.3, it is required to set PKG_CONFIG_LIBDIR in addition to
# --with-pkg-config-libdir.
# Indeed, the configure script expects the directory passed as
# --with-pkg-config-libdir argument to exist to properly complete.
#
# Give configure `--disable-lib_suffixes' option to remove the `w' suffix
# related to wide character support.
ncurses_stage_config_args := \
	$(ncurses_common_config_args) \
	--with-pkg-config-libdir='$(stagedir)/lib/pkgconfig' \
	PKG_CONFIG_LIBDIR='$(stagedir)/lib/pkgconfig' \
	--without-manpages \
	$(stage_config_flags)

$(call gen_deps,stage-ncurses,stage-pkg-config)

config_stage-ncurses    = $(call ncurses_config_cmds,\
                                 stage-ncurses,\
                                 $(stagedir),\
                                 $(ncurses_stage_config_args))
build_stage-ncurses     = $(call ncurses_build_cmds,stage-ncurses)
clean_stage-ncurses     = $(call ncurses_clean_cmds,stage-ncurses)
install_stage-ncurses   = $(call ncurses_install_cmds,stage-ncurses,\
                                                      $(stagedir))
uninstall_stage-ncurses = $(call ncurses_uninstall_cmds,stage-ncurses,\
                                                        $(stagedir))

$(call gen_config_rules_with_dep,stage-ncurses,ncurses,config_stage-ncurses)
$(call gen_clobber_rules,stage-ncurses)
$(call gen_build_rules,stage-ncurses,build_stage-ncurses)
$(call gen_clean_rules,stage-ncurses,clean_stage-ncurses)
$(call gen_install_rules,stage-ncurses,install_stage-ncurses)
$(call gen_uninstall_rules,stage-ncurses,uninstall_stage-ncurses)
$(call gen_no_check_rules,stage-ncurses,Test must be done manualy)
$(call gen_dir_rules,stage-ncurses)

################################################################################
# Final definitions
################################################################################

# As of version 6.3, it is required to set PKG_CONFIG_LIBDIR in addition to
# --with-pkg-config-libdir.
# Indeed, the configure script expects the directory passed as
# --with-pkg-config-libdir argument to exist to properly complete.
ncurses_final_config_args := \
	$(ncurses_common_config_args) \
	--with-pkg-config-libdir='$(PREFIX)/lib/pkgconfig' \
	PKG_CONFIG_LIBDIR='$(PREFIX)/lib/pkgconfig' \
	$(final_config_flags)

# Requires tic from staging area to build (see ncurses_install_cmds macro)
$(call gen_deps,final-ncurses,stage-pkg-config stage-ncurses)

config_final-ncurses    = $(call ncurses_config_cmds,\
                                 final-ncurses,\
                                 $(PREFIX),\
                                 $(ncurses_final_config_args))
build_final-ncurses     = $(call ncurses_build_cmds,final-ncurses)
clean_final-ncurses     = $(call ncurses_clean_cmds,final-ncurses)
install_final-ncurses   = $(call ncurses_install_cmds,final-ncurses,\
                                                      $(PREFIX),\
                                                      $(finaldir))
uninstall_final-ncurses = $(call ncurses_uninstall_cmds,final-ncurses,\
                                                        $(PREFIX),\
                                                        $(finaldir))

$(call gen_config_rules_with_dep,final-ncurses,ncurses,config_final-ncurses)
$(call gen_clobber_rules,final-ncurses)
$(call gen_build_rules,final-ncurses,build_final-ncurses)
$(call gen_clean_rules,final-ncurses,clean_final-ncurses)
$(call gen_install_rules,final-ncurses,install_final-ncurses)
$(call gen_uninstall_rules,final-ncurses,uninstall_final-ncurses)
$(call gen_no_check_rules,final-ncurses,Test must be done manualy)
$(call gen_dir_rules,final-ncurses)
