################################################################################
# openssl modules
################################################################################

openssl_dist_url  := https://www.openssl.org/source/openssl-3.5.0.tar.gz
openssl_dist_sum  := 39cc80e2843a2ee30f3f5de25cd9d0f759ad8de71b0b39f5a679afaaa74f4eb58d285ae50e29e4a27b139b49343ac91d1f05478f96fb0c6b150f16d7b634676f
openssl_dist_name := $(notdir $(openssl_dist_url))
openssl_vers      := $(patsubst openssl-%.tar.gz,%,$(openssl_dist_name))
openssl_brief     := Secure Sockets Layer toolkit
openssl_home      := https://www.openssl.org/

define openssl_desc
Implementation of the SSL and TLS cryptographic protocols for secure
communication over the Internet.

It ships with tools and libraries useful for cryptographic operations such as:

* creating RSA, DH, and DSA key parameters;
* creating X.509 certificates, CSRs, and CRLs;
* calculating message digests;
* encrypting and decrypting with ciphers;
* testing SSL/TLS clients and servers;
* handling S/MIME signed or encrypted mail.
endef

define fetch_openssl_dist
$(call download_csum,$(openssl_dist_url),\
                     $(openssl_dist_name),\
                     $(openssl_dist_sum))
endef
$(call gen_fetch_rules,openssl,openssl_dist_name,fetch_openssl_dist)

define xtract_openssl
$(call rmrf,$(srcdir)/openssl)
$(call untar,$(srcdir)/openssl,\
             $(FETCHDIR)/$(openssl_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,openssl,xtract_openssl)

$(call gen_dir_rules,openssl)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define openssl_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(stagedir)/bin/perl $(srcdir)/openssl/Configure --prefix='$(strip $(2))' \
                                                 $(3) \
                                                 $(verbose)
endef

# $(1): targets base name / module name
define openssl_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         PATH="$(stagedir)/bin:$(PATH)" \
         $(verbose)
endef

# $(1): targets base name / module name
define openssl_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define openssl_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         PATH="$(stagedir)/bin:$(PATH)" \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define openssl_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call rmrf,$(strip $(3))$(strip $(2))/etc/ssl)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define openssl_check_cmds
+env LD_LIBRARY_PATH="$(stage_lib_path)" \
 $(MAKE) --directory $(builddir)/$(strip $(1)) \
         test \
         PATH="$(stagedir)/bin:$(PATH)"
endef

# Diffie Hellman, SSL and all TLS required for python SSL support
# RIPEMD160 required by rhash module
# DES required by curl NTLM support
# DSA required by the python cryptography module
#
# As of version 3.10, Python SSL module requires OpenSSL version 1.1.1 or newer
# but also requires some deprecated TLS related functions that have been
# deprecated in API 1.1.0... Hence remove the no-deprecated configure option.
openssl_common_config_args := --release \
                              shared \
                              no-capieng \
                              no-padlockeng \
                              no-md2 \
                              no-md4 \
                              no-rc2 \
                              no-rc4 \
                              no-rc5 \
                              no-idea \
                              no-camellia \
                              no-aria \
                              no-cast \
                              no-bf \
                              no-egd \
                              no-mdc2 \
                              no-psk \
                              no-sm2 \
                              no-sm3 \
                              no-sm4\
                              no-whirlpool \
                              no-filenames \
                              no-gost \
                              threads \
                              zlib-dynamic \
                              enable-ktls \
                              enable-acvp-tests \
                              enable-buildtest-c++ \
                              enable-fips \
                              $(if $(mach_is_64bits),enable-ec_nistp_64_gcc_128) \
                              $(if $(arch_is_x86_64),linux-x86_64)

################################################################################
# Staging definitions
################################################################################

openssl_stage_config_args := $(openssl_common_config_args) \
                             --openssldir="$(stagedir)/etc/ssl" \
                             --libdir="$(stagedir)/lib" \
                             $(stage_config_flags)

$(call gen_deps,stage-openssl,stage-perl stage-zlib)

config_stage-openssl    = $(call openssl_config_cmds,\
                                 stage-openssl,\
                                 $(stagedir),\
                                 $(openssl_stage_config_args))
build_stage-openssl     = $(call openssl_build_cmds,stage-openssl)
clean_stage-openssl     = $(call openssl_clean_cmds,stage-openssl)
install_stage-openssl   = $(call openssl_install_cmds,stage-openssl,\
                                                      $(stagedir))
uninstall_stage-openssl = $(call openssl_uninstall_cmds,stage-openssl,\
                                                        $(stagedir))
check_stage-openssl     = $(call openssl_check_cmds,stage-openssl)

$(call gen_config_rules_with_dep,stage-openssl,openssl,config_stage-openssl)
$(call gen_clobber_rules,stage-openssl)
$(call gen_build_rules,stage-openssl,build_stage-openssl)
$(call gen_clean_rules,stage-openssl,clean_stage-openssl)
$(call gen_install_rules,stage-openssl,install_stage-openssl)
$(call gen_uninstall_rules,stage-openssl,uninstall_stage-openssl)
$(call gen_check_rules,stage-openssl,check_stage-openssl)
$(call gen_dir_rules,stage-openssl)

################################################################################
# Final definitions
################################################################################

openssl_final_config_args := $(openssl_common_config_args) \
                             --openssldir="$(PREFIX)/etc/ssl" \
                             --libdir="$(PREFIX)/lib" \
                             $(final_config_flags)

$(call gen_deps,final-openssl,stage-perl stage-zlib)

config_final-openssl    = $(call openssl_config_cmds,\
                                 final-openssl,\
                                 $(PREFIX),\
                                 $(openssl_final_config_args))
build_final-openssl     = $(call openssl_build_cmds,final-openssl)
clean_final-openssl     = $(call openssl_clean_cmds,final-openssl)

final-openssl_perl_fixups := bin/c_rehash \
                             etc/ssl/misc/tsget.pl \
                             etc/ssl/misc/CA.pl

define install_final-openssl
$(call openssl_install_cmds,final-openssl,$(PREFIX),$(finaldir))
$(call fixup_shebang,$(addprefix $(finaldir)$(PREFIX)/,\
                                 $(final-openssl_perl_fixups)),\
                     $(PREFIX)/bin/perl)
endef

uninstall_final-openssl = $(call openssl_uninstall_cmds,final-openssl,\
                                                        $(PREFIX),\
                                                        $(finaldir))
check_final-openssl     = $(call openssl_check_cmds,final-openssl)

$(call gen_config_rules_with_dep,final-openssl,openssl,config_final-openssl)
$(call gen_clobber_rules,final-openssl)
$(call gen_build_rules,final-openssl,build_final-openssl)
$(call gen_clean_rules,final-openssl,clean_final-openssl)
$(call gen_install_rules,final-openssl,install_final-openssl)
$(call gen_uninstall_rules,final-openssl,uninstall_final-openssl)
$(call gen_check_rules,final-openssl,check_final-openssl)
$(call gen_dir_rules,final-openssl)
