#!/bin/env perl
# AIDE delivering mail report to systems administrators team.
# This was test with RHEL4+.
# Copyright (C) 2008 Wilmer Jaramillo M. <wilmer@fedoraproject.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use Sys::Hostname;
use File::Copy;

my $node = hostname;
my $to = 'wilmer@fedoraproject.org';
my $from = 'noreply@mydomain.ve';
my $subject = "AIDE Report $node";
my $file = "/tmp/aide-report";

# :: Identificar cambios y reportar en archivo;
open(CHECK, "|/usr/sbin/aide --check >/tmp/aide-report");
close(CHECK);

# ;; Una vez reportados, re-inicializar y sustituir base de datos de AIDE:
open(INIT, "|/usr/sbin/aide --init >/dev/null 2>&1");
close(INIT);
copy("/var/lib/aide/aide.db.new.gz","/var/lib/aide/aide.db.gz") ||  die "Copia de re-inicializacion fallo:".$!;

# Si no se detectaron cambios en la base de datos se omite el envio de correo.
# Depende de que el parametro 'verbose' en aide.conf tenga un valor <= 3.
die "No se detectaron cambios en la base de datos.\n" if -z $file;

# Envio de reporte por correo electronico al equipo de servidores.
open(FILE, "<", "/tmp/aide-report") || die "Reporte no encontrado:".$!;
open(MAIL, "|/usr/sbin/sendmail -t");
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n\n";
while (<FILE>) {
	print MAIL $_;
};
 
close(MAIL);
close(FILE);
exit

# vim: ts=4 sw=4 nu bg=dark
