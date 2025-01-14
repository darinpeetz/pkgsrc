$NetBSD: patch-nss_coreconf_NetBSD.mk,v 1.4 2021/05/05 16:54:03 wiz Exp $

Match more closely to OpenBSD.mk, and in particular, hide symbols (MAPFILE).

- fix wrong value of CPU_ARCH on NetBSD/evbarm-earmv7f
- s/aarch64eb/aarch64/

https://bugzilla.mozilla.org/show_bug.cgi?id=1709654

--- nss/coreconf/NetBSD.mk.orig	2021-04-15 16:17:44.000000000 +0000
+++ nss/coreconf/NetBSD.mk
@@ -5,9 +5,10 @@
 
 include $(CORE_DEPTH)/coreconf/UNIX.mk
 
-DEFAULT_COMPILER	= gcc
-CC			= gcc
-CCC			= g++
+CC			?= gcc
+CXX			?= g++
+DEFAULT_COMPILER	= ${CC}
+CCC			= ${CXX}
 RANLIB			= ranlib
 
 CPU_ARCH		:= $(shell uname -p)
@@ -15,16 +16,14 @@ ifeq ($(CPU_ARCH),i386)
 OS_REL_CFLAGS		= -Di386
 CPU_ARCH		= x86
 endif
-
-ifndef OBJECT_FMT
-OBJECT_FMT		:= $(shell if echo __ELF__ | $${CC:-cc} -E - | grep -q __ELF__ ; then echo a.out ; else echo ELF ; fi)
+ifeq (,$(filter-out earm%,$(CPU_ARCH)))
+CPU_ARCH		= arm
+endif
+ifeq ($(CPU_ARCH),aarch64eb)
+CPU_ARCH		= aarch64
 endif
 
-ifeq ($(OBJECT_FMT),ELF)
 DLL_SUFFIX		= so
-else
-DLL_SUFFIX		= so.1.0
-endif
 
 OS_CFLAGS		= $(DSO_CFLAGS) $(OS_REL_CFLAGS) -Wall -Wno-switch -pipe -DNETBSD -Dunix -DHAVE_STRERROR -DHAVE_BSD_FLOCK
 
@@ -33,9 +32,16 @@ OS_LIBS			= -lcompat
 ARCH			= netbsd
 
 DSO_CFLAGS		= -fPIC -DPIC
-DSO_LDOPTS		= -shared
-ifeq ($(OBJECT_FMT),ELF)
-DSO_LDOPTS		+= -Wl,-soname,lib$(LIBRARY_NAME)$(LIBRARY_VERSION).$(DLL_SUFFIX)
+DSO_LDOPTS		= -shared -Wl,-soname,lib$(LIBRARY_NAME)$(LIBRARY_VERSION).$(DLL_SUFFIX)
+
+#
+# The default implementation strategy for NetBSD is pthreads.
+#
+ifndef CLASSIC_NSPR
+USE_PTHREADS		= 1
+DEFINES			+= -D_THREAD_SAFE -D_REENTRANT
+OS_LIBS			+= -pthread
+DSO_LDOPTS		+= -pthread
 endif
 
 ifdef LIBRUNPATH
@@ -44,12 +50,8 @@ endif
 
 MKSHLIB			= $(CC) $(DSO_LDOPTS)
 ifdef MAPFILE
-# Add LD options to restrict exported symbols to those in the map file
+	MKSHLIB += -Wl,--version-script,$(MAPFILE)
 endif
-# Change PROCESS to put the mapfile in the correct format for this platform
-PROCESS_MAP_FILE = cp $< $@
-
-
-G++INCLUDES		= -I/usr/include/g++
+PROCESS_MAP_FILE = grep -v ';-' $< | \
+        sed -e 's,;+,,' -e 's; DATA ;;' -e 's,;;,,' -e 's,;.*,;,' > $@
 
-INCLUDES		+= -I/usr/X11R6/include
