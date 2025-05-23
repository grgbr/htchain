################################################################################
# util-linux modules
################################################################################

util-linux_dist_url  := https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.41/util-linux-2.41.tar.xz
util-linux_dist_sum  := 58be27a08cc875d1a5f4dbdfeef1d4c3e2d728ac53f94b747fcc4b1454e261c0e26b367ef2649bbad40ca569d7fa6805e47e0e571b66465d6a7647799e2d0af0
util-linux_dist_name := $(notdir $(util-linux_dist_url))
util-linux_vers      := $(patsubst util-linux-%.tar.xz,%,$(util-linux_dist_name))
util-linux_brief     := Miscellaneous Linux system utilities
util-linux_home      := http://www.kernel.org/pub/linux/utils/util-linux/

define util-linux_desc
This package contains a number of important utilities, most of which are
oriented towards maintenance of your system. Some of the more important
utilities included in this package allow you to view kernel messages, create new
filesystems, view block device information, interface with real time clock, etc.
endef

define fetch_util-linux_dist
$(call download_csum,$(util-linux_dist_url),\
                     $(util-linux_dist_name),\
                     $(util-linux_dist_sum))
endef
$(call gen_fetch_rules,util-linux,util-linux_dist_name,fetch_util-linux_dist)

define xtract_util-linux
$(call rmrf,$(srcdir)/util-linux)
$(call untar,$(srcdir)/util-linux,\
             $(FETCHDIR)/$(util-linux_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,util-linux,xtract_util-linux)

$(call gen_dir_rules,util-linux)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define util-linux_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/util-linux/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define util-linux_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define util-linux_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define util-linux_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define util-linux_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define util-linux_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

util-linux_common_config_args := \
	--enable-silent-rules \
	--enable-shared \
	--enable-static \
	--disable-assert \
	--disable-all-programs \
	--without-udev \
	--without-systemd \
	--enable-libuuid \
	--enable-libuuid-force-uuidd \
	--enable-libblkid \
	--enable-libmount

################################################################################
# Staging definitions
################################################################################

util-linux_stage_config_args := \
	$(util-linux_common_config_args) \
	--disable-gtk-doc \
	--disable-nls \
	--disable-asciidoc \
	--disable-poman \
	PYTHON=':' \
	$(filter-out PYTHON=%,$(call stage_config_flags,$(rpath_flags)))

$(call gen_deps,stage-util-linux,stage-pkg-config)

config_stage-util-linux    = $(call util-linux_config_cmds,\
                                    stage-util-linux,\
                                    $(stagedir),\
                                    $(util-linux_stage_config_args))
build_stage-util-linux     = $(call util-linux_build_cmds,stage-util-linux)
clean_stage-util-linux     = $(call util-linux_clean_cmds,stage-util-linux)
install_stage-util-linux   = $(call util-linux_install_cmds,stage-util-linux,\
                                                            $(stagedir))
uninstall_stage-util-linux = $(call util-linux_uninstall_cmds,stage-util-linux,\
                                                              $(stagedir))
check_stage-util-linux     = $(call util-linux_check_cmds,stage-util-linux)

$(call gen_config_rules_with_dep,stage-util-linux,util-linux,config_stage-util-linux)
$(call gen_clobber_rules,stage-util-linux)
$(call gen_build_rules,stage-util-linux,build_stage-util-linux)
$(call gen_clean_rules,stage-util-linux,clean_stage-util-linux)
$(call gen_install_rules,stage-util-linux,install_stage-util-linux)
$(call gen_uninstall_rules,stage-util-linux,uninstall_stage-util-linux)
$(call gen_check_rules,stage-util-linux,check_stage-util-linux)
$(call gen_dir_rules,stage-util-linux)

################################################################################
# Final definitions
################################################################################

util-linux_final_config_args := \
	$(util-linux_common_config_args) \
	--enable-nls \
	$(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-util-linux,\
                stage-pkg-config stage-gettext stage-texinfo stage-python)

config_final-util-linux    = $(call util-linux_config_cmds,\
                                    final-util-linux,\
                                    $(PREFIX),\
                                    $(util-linux_final_config_args))
build_final-util-linux     = $(call util-linux_build_cmds,final-util-linux)
clean_final-util-linux     = $(call util-linux_clean_cmds,final-util-linux)
install_final-util-linux   = $(call util-linux_install_cmds,final-util-linux,\
                                                            $(PREFIX),\
                                                            $(finaldir))
uninstall_final-util-linux = $(call util-linux_uninstall_cmds,final-util-linux,\
                                                              $(PREFIX),\
                                                              $(finaldir))
check_final-util-linux     = $(call util-linux_check_cmds,final-util-linux)

$(call gen_config_rules_with_dep,final-util-linux,\
                                 util-linux,\
                                 config_final-util-linux)
$(call gen_clobber_rules,final-util-linux)
$(call gen_build_rules,final-util-linux,build_final-util-linux)
$(call gen_clean_rules,final-util-linux,clean_final-util-linux)
$(call gen_install_rules,final-util-linux,install_final-util-linux)
$(call gen_uninstall_rules,final-util-linux,uninstall_final-util-linux)
$(call gen_check_rules,final-util-linux,check_final-util-linux)
$(call gen_dir_rules,final-util-linux)
