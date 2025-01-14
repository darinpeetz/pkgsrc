# $NetBSD: buildlink3.mk,v 1.2 2021/05/10 17:31:27 nia Exp $

BUILDLINK_TREE+=	mysql-server

.if !defined(MYSQL_SERVER_BUILDLINK3_MK)
MYSQL_SERVER_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.mysql-server+=	mariadb-server>=10.4.0
BUILDLINK_ABI_DEPENDS.mysql-server+=	mariadb-server>=10.4.0
BUILDLINK_PKGSRCDIR.mysql-server?=	../../databases/mariadb104-server
BUILDLINK_LIBDIRS.mysql-server+=	lib

.endif	# MYSQL_SERVER_BUILDLINK3_MK

BUILDLINK_TREE+=	-mysql-server
