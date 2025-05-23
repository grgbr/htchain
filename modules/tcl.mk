################################################################################
# tcl modules
#
# !Warning! TCL test suites requires IPv6 support enabled to complete.
################################################################################

tcl_dist_url  := https://prdownloads.sourceforge.net/tcl/tcl9.0.1-src.tar.gz
tcl_dist_sum  := 8ef8289bd86b4cc2597d63f4b460fa4a67da66dbb1bafa29cb8cd960867d07636f12713ecb1a95a96bd6c284b6f0f4264ff96da2feeb52a5a9795f036fa346c3
tcl_vers      := $(patsubst tcl%-src.tar.gz,%,$(notdir $(tcl_dist_url)))
tcl_vers_toks := $(subst .,$(space),$(tcl_vers))
tcl_vers_maj  := $(word 1,$(tcl_vers_toks))
tcl_vers_min  := $(word 2,$(tcl_vers_toks))
tcl_dist_name := tcl-$(tcl_vers).tar.gz
tcl_brief     := Tcl, the Tool Command Language
tcl_home      := http://www.tcl.tk/
define tcl_patches
# $(call patch,$(srcdir)/tcl,$(PATCHDIR)/tcl-8.6.12-000-skip_auto_path_prefix_dir.patch,-p1)
# $(call patch,$(srcdir)/tcl,$(PATCHDIR)/tcl-8.6.12-001-fix_fcmd_test_home_dir.patch,-p1)
# $(call patch,$(srcdir)/tcl,$(PATCHDIR)/tcl-8.6.12-002-fix_thread_pkg_gdbm_not_found.patch,-p1)
endef

# List of packages to build shipped with TCL.
tcl_packages  := itcl4.2.2 tdbc1.1.3 thread2.8.7 tdbcsqlite3-1.1.3

define tcl_desc
Tcl is a powerful, easy to use, embeddable, cross-platform interpreted scripting
language.
endef

define fetch_tcl_dist
$(call download_csum,$(tcl_dist_url),\
                     $(tcl_dist_name),\
                     $(tcl_dist_sum))
endef
$(call gen_fetch_rules,tcl,tcl_dist_name,fetch_tcl_dist)

define xtract_tcl
$(call rmrf,$(srcdir)/tcl)
$(call untar,$(srcdir)/tcl,\
             $(FETCHDIR)/$(tcl_dist_name),\
             --strip-components=1)
$(tcl_patches)
endef
$(call gen_xtract_rules,tcl,xtract_tcl)

$(call gen_dir_rules,tcl)

# $(1): targets base name / module name
# $(2): package name
# $(3): build / install prefix
# $(4): configure arguments
#
# We have to run autoreconf since we patched thread package autoconf logic...
define tcl_config_pkg_cmds
$(call mkdir,$(builddir)/$(strip $(1))/pkgs/$(strip $(2)))
cd $(srcdir)/tcl/pkgs/$(strip $(2)) && $(stagedir)/bin/autoreconf -if
cd $(builddir)/$(strip $(1))/pkgs/$(strip $(2)) && \
$(srcdir)/tcl/pkgs/$(strip $(2))/configure \
	--with-tcl="$(builddir)/$(strip $(1))" \
	--prefix="$(strip $(3))" \
	--libdir="$(strip $(3))/lib/tcltk" \
	--includedir="$(strip $(3))/include/tcl$(tcl_vers_maj).$(tcl_vers_min)" \
	--mandir="$(strip $(3))/share/man" \
	TCL_LIBRARY="$(strip $(3))/lib/tcltk/tcl$(tcl_vers_maj)" \
	TCL_PACKAGE_PATH="$(strip $(3))/lib/tcltk" \
	$(4) \
	$(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define tcl_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/tcl/unix/configure \
	--prefix="$(strip $(2))" \
	--includedir="$(strip $(2))/include/tcl$(tcl_vers_maj).$(tcl_vers_min)" \
	--mandir="$(strip $(2))/share/man" \
	TCL_LIBRARY="$(strip $(2))/lib/tcltk/tcl$(tcl_vers_maj)" \
	TCL_PACKAGE_PATH="$(strip $(2))/lib/tcltk" \
	$(3) \
	$(verbose)
$(foreach p,\
          $(tcl_packages),\
          $(call tcl_config_pkg_cmds,$(1),$(p),$(2),$(3))$(newline))
endef

# $(1): targets base name / module name
# $(2): package name
# $(3): make arguments
define tcl_build_pkg_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/pkgs/$(strip $(2)) \
         $(3) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): make arguments
define tcl_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         $(2) \
         $(verbose)
$(foreach p,\
          $(tcl_packages),\
          $(call tcl_build_pkg_cmds,$(1),$(p),$(2))$(newline))
endef

# $(1): targets base name / module name
define tcl_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): package name
# $(3): optional install destination directory
# $(4): make arguments
define tcl_install_pkg_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/pkgs/$(strip $(2)) \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         install \
         $(4) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
# $(4): optional install destination directory
define _tcl_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
         $(3) \
         $(verbose)
$(foreach p,\
          $(tcl_packages),\
          $(call tcl_install_pkg_cmds,$(1),$(p),$(4))$(newline))
$(call slink,tclsh$(tcl_vers_maj).$(tcl_vers_min),\
             $(strip $(4))$(strip $(2))/bin/tclsh)
$(call slink,tcl$(tcl_vers_maj).$(tcl_vers_min),\
             $(strip $(4))$(strip $(2))/include/tcl)
$(CHMOD) u+w \
         $(strip $(4))$(strip $(2))/lib/libtcl$(tcl_vers_maj).$(tcl_vers_min).so \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
# $(4): optional install destination directory
define tcl_install_cmds
$(call _tcl_install_cmds,$(1),$(2),$(3),$(installdir)/$(strip $(1)))
$(call _tcl_install_cmds,$(1),$(2),$(3),$(4))
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define tcl_uninstall_cmds
$(call uninstall_from_refdir,$(installdir)/$(strip $(1)),$(2))
$(call rmrf,$(installdir)/$(strip $(1)))
endef

# $(1): targets base name / module name
# $(2): package name
define tcl_check_pkg_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1))/pkgs/$(strip $(2)) \
         test \
         LD_LIBRARY_PATH="$(stagedir)/lib"
endef

# $(1): targets base name / module name
define tcl_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         test-tcl \
         LD_LIBRARY_PATH="$(stagedir)/lib"
$(foreach p,\
          $(tcl_packages),\
          $(call tcl_check_pkg_cmds,$(1),$(p))$(newline))
endef

tcl_common_args := --enable-threads \
                   --enable-shared \
                   --disable-symbols \
                   --enable-man-symlinks \
                   --with-gdbm="$(stagedir)" \
                   ac_cv_func_sin=no \
                   $(if $(mach_is_64bits),--enable-64bit)

################################################################################
# Staging definitions
################################################################################

tcl_stage_config_args := $(tcl_common_args) \
                         --disable-langinfo \
                         $(stage_config_flags)

$(call gen_deps,stage-tcl,stage-pkg-config stage-gdbm stage-autoconf)
$(call gen_check_deps,final-tcl,stage-sqlite)

config_stage-tcl    = $(call tcl_config_cmds,stage-tcl,\
                                             $(stagedir),\
                                             $(tcl_stage_config_args))
build_stage-tcl     = $(call tcl_build_cmds,stage-tcl,\
                                            binaries libraries)
clean_stage-tcl     = $(call tcl_clean_cmds,stage-tcl)
install_stage-tcl   = $(call tcl_install_cmds,stage-tcl,\
                                              $(stagedir),\
                                              install-binaries \
                                              install-libraries \
                                              install-headers)
uninstall_stage-tcl = $(call tcl_uninstall_cmds,stage-tcl)
check_stage-tcl     = $(call tcl_check_cmds,stage-tcl)

$(call gen_config_rules_with_dep,stage-tcl,tcl,config_stage-tcl)
$(call gen_clobber_rules,stage-tcl)
$(call gen_build_rules,stage-tcl,build_stage-tcl)
$(call gen_clean_rules,stage-tcl,clean_stage-tcl)
$(call gen_install_rules,stage-tcl,install_stage-tcl)
$(call gen_uninstall_rules,stage-tcl,uninstall_stage-tcl)
$(call gen_check_rules,stage-tcl,check_stage-tcl)
$(call gen_dir_rules,stage-tcl)

################################################################################
# Final definitions
################################################################################

# Tell this brain dead configure script where to find gdbm using directory
# located under stage-gdbm build directory since it expects to find libgdbm.so
# and gdbm.h within the same directory or within hard-coded staging / prefixed final
# directory hierarchy (hence, not working when installing using a DESTDIR...)
#
# See modules/gdbm.mk gdbm_build_cmds() macros which creates the required
# symlink to workaround this weakness.
tcl_final_config_args := $(tcl_common_args) \
                         --enable-langinfo \
                         $(final_config_flags)

$(call gen_deps,final-tcl,stage-pkg-config stage-gdbm stage-autoconf)
$(call gen_check_deps,final-tcl,stage-sqlite)

config_final-tcl    = $(call tcl_config_cmds,final-tcl,\
                                             $(PREFIX),\
                                             $(tcl_final_config_args))
build_final-tcl     = $(call tcl_build_cmds,final-tcl,\
                                            binaries libraries doc)
clean_final-tcl     = $(call tcl_clean_cmds,final-tcl)
install_final-tcl   = $(call tcl_install_cmds,final-tcl,\
                                              $(PREFIX),\
                                              install-binaries \
                                              install-libraries \
                                              install-headers \
                                              install-doc \
                                              install-msgs,\
                                              $(finaldir))
uninstall_final-tcl = $(call tcl_uninstall_cmds,final-tcl,$(finaldir))
check_final-tcl     = $(call tcl_check_cmds,final-tcl)

$(call gen_config_rules_with_dep,final-tcl,tcl,config_final-tcl)
$(call gen_clobber_rules,final-tcl)
$(call gen_build_rules,final-tcl,build_final-tcl)
$(call gen_clean_rules,final-tcl,clean_final-tcl)
$(call gen_install_rules,final-tcl,install_final-tcl)
$(call gen_uninstall_rules,final-tcl,uninstall_final-tcl)
$(call gen_check_rules,final-tcl,check_final-tcl)
$(call gen_dir_rules,final-tcl)
