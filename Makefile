# New ports collection makefile for:	lism
# Date created:		2011-04-27
# Whom:			TAKATSU Tomonari <tota@FreeBSD.org>
#
# $FreeBSD$
#

PORTNAME=	lism
PORTVERSION=	2.3.12
CATEGORIES=	sysutils net databases
MASTER_SITES=	SFJP
MASTER_SITE_SUBDIR=	${PORTNAME}/54054
DISTNAME=	${PORTNAME:U}-${PORTVERSION}

MAINTAINER=	tota@FreeBSD.org
COMMENT=	LDAP Identity Synchronization Manager

LICENSE=	LGPL21

RUN_DEPENDS=	${LOCALBASE}/libexec/slapd:${PORTSDIR}/net/openldap24-server \
		${SITE_PERL}/Net/LDAP.pm:${PORTSDIR}/net/p5-perl-ldap \
		${SITE_PERL}/${PERL_ARCH}/XML/LibXML.pm:${PORTSDIR}/textproc/p5-XML-LibXML \
		${SITE_PERL}/XML/Simple.pm:${PORTSDIR}/textproc/p5-XML-Simple \
		${SITE_PERL}/${PERL_ARCH}/Digest/SHA1.pm:${PORTSDIR}/security/p5-Digest-SHA1 \
		${SITE_PERL}/Config/General.pm:${PORTSDIR}/devel/p5-Config-General \
		${SITE_PERL}/SOAP/Lite.pm:${PORTSDIR}/net/p5-SOAP-Lite \
		${SITE_PERL}/CGI/Session.pm:${PORTSDIR}/www/p5-CGI-Session

PERL_CONFIGURE=	yes

MAN3=	LISM.3 \
	LISM::Handler.3 \
	LISM::Handler::Check.3 \
	LISM::Handler::Rewrite.3 \
	LISM::Handler::Script.3 \
	LISM::Handler::Setval.3 \
	LISM::Storage.3 \
	LISM::Storage::AD.3 \
	LISM::Storage::CSV.3 \
	LISM::Storage::GAE.3 \
	LISM::Storage::GoogleApps.3 \
	LISM::Storage::LDAP.3 \
	LISM::Storage::SOAP.3 \
	LISM::Storage::SQL.3

SCRIPTS=	lismcluster lismconfig lismsync

OPTIONS=	GOOGLEAPPS "Sync ID to Google Apps" off

.include <bsd.port.pre.mk>

.if exists(${LOCALBASE}/libexec/slapd) && !exists(${LOCALBASE}/libexec/openldap/back_perl.so)
IGNORE=	please reinstall openldap server with PERL support
.endif

.if defined(WITH_GOOGLEAPPS)
RUN_DEPENDS+=	${SITE_PERL}/VUser/Google/ProvisioningAPI.pm:${PORTSDIR}/www/p5-VUser-Google-ProvisioningAPI
.endif

post-install:
	${INSTALL_DATA} ${INSTALL_WRKSRC}/conf/lism.conf ${PREFIX}/etc/lism.conf.sample
	[ -f ${PREFIX}/etc/lism.conf ] || \
		${CP} ${PREFIX}/etc/lism.conf.sample \
		${PREFIX}/etc/lism.conf
.for s in ${SCRIPTS}
	${INSTALL_SCRIPT} ${INSTALL_WRKSRC}/scripts/${s} ${PREFIX}/sbin/
.endfor

x-generate-plist:
	${ECHO} '@unexec if cmp -s %D/etc/lism.conf.sample %D/etc/lism.conf; then rm -f %D/etc/lism.conf; fi' > pkg-plist.new
	${ECHO} etc/lism.conf.sample >> pkg-plist.new
	${ECHO} '@exec if [ ! -f %D/etc/lism.conf ] ; then cp -p %D/%F %B/lism.conf; fi' >> pkg-plist.new
.for s in ${SCRIPTS}
	${ECHO} sbin/${s} >> pkg-plist.new
.endfor
	${ECHO} %%SITE_PERL%%/LISM.pm >> pkg-plist.new
	${FIND} ${SITE_PERL}/${PORTNAME:U} -type f | ${SORT} | \
	${SED} -e 's,${SITE_PERL},%%SITE_PERL%%,' >> pkg-plist.new
	${FIND} ${SITE_PERL}/${PORTNAME:U} -type d -depth | ${SORT} -r | \
	${SED} -e 's,${SITE_PERL},@dirrm %%SITE_PERL%%,' >> pkg-plist.new

.include <bsd.port.post.mk>
