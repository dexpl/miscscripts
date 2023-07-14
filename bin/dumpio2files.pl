#!/usr/bin/env perl
#===============================================================================
#
#         FILE: dumpio2files.pl
#
#        USAGE: ./dumpio2files.pl [error_log...]
#
#  DESCRIPTION: A quick and extremely dirty hack to split Apache error_log
#  produced by mod_dumpio into files
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Vadim V. Raskhozhev
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 08.02.2023 13:18:43
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use autodie;

use File::Path qw(make_path);
use feature 'say';

my $basedir = $ENV{'DIO_BASE'} // '/var/tmp/dumpio';
my %outfiles;
while (<>) {
    # Example:
    # [Wed Feb 08 11:52:04.169518 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): POST /cardio/hs/integration/cardio/micard HTTP/1.1\r\n
    # Another example:
    # [Tue Mar 28 17:51:22.645563 2023] [dumpio:trace7] [pid 2448:tid 140229608371968] mod_dumpio.c(103): [client 188.170.189.153:62933] mod_dumpio:  dumpio_in (data-HEAP): \r\n
    next unless /\[pid (\d+)(?::tid \d+)*\] .* \[client ([\d\.]+):(\d+)\] mod_dumpio:\s+dumpio_(\S+) \(data-HEAP\):\s+(.*)/;
    my ($pid, $clientip, $clientport, $direction, $data) = ($1, $2, $3, $4, $5);
    next if $data =~ / bytes$/;
    my $datadir = "${basedir}/${pid}/${clientip}.${clientport}";
    my $file = "${datadir}/${direction}.txt";
    stat "${datadir}" || make_path "${datadir}";
    open my $fh, '>>', $file;
    $data =~ s,\\x?([[:xdigit:]]{2}),chr(hex($1)),eig;
    $data =~ s,\\r,\n,g;
    $data =~ s,\\n,,g;
    print $fh $data;
    close $fh;
}
__END__

error_log contents example:

[Wed Feb 08 11:52:04.169278 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169505 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 52 bytes
[Wed Feb 08 11:52:04.169518 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): POST /cardio/hs/integration/cardio/micard HTTP/1.1\r\n
[Wed Feb 08 11:52:04.169548 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169556 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 21 bytes
[Wed Feb 08 11:52:04.169561 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): Accept-Language: ru\r\n
[Wed Feb 08 11:52:04.169568 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169574 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 39 bytes
[Wed Feb 08 11:52:04.169580 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): Content-Type: text/xml; charset=UTF-8\r\n
[Wed Feb 08 11:52:04.169587 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169593 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 25 bytes
[Wed Feb 08 11:52:04.169598 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): Content-Length: 2818078\r\n
[Wed Feb 08 11:52:04.169605 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169611 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 24 bytes
[Wed Feb 08 11:52:04.169616 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): Connection: Keep-Alive\r\n
[Wed Feb 08 11:52:04.169623 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169629 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 32 bytes
[Wed Feb 08 11:52:04.169634 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): Accept-Encoding: gzip, deflate\r\n
[Wed Feb 08 11:52:04.169640 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169658 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 25 bytes
[Wed Feb 08 11:52:04.169664 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): User-Agent: Mozilla/5.0\r\n
[Wed Feb 08 11:52:04.169671 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169677 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 25 bytes
[Wed Feb 08 11:52:04.169682 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): Host: 192.168.0.10:8666\r\n
[Wed Feb 08 11:52:04.169688 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [getline-blocking] 0 readbytes
[Wed Feb 08 11:52:04.169694 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 2 bytes
[Wed Feb 08 11:52:04.169699 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): \r\n
[Wed Feb 08 11:52:04.312367 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(140): [client 172.18.0.3:34264] mod_dumpio: dumpio_in [readbytes-blocking] 8192 readbytes
[Wed Feb 08 11:52:04.312525 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): 7755 bytes
[Wed Feb 08 11:52:04.312539 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_in (data-HEAP): <?xml version="1.0" encoding="UTF-8"?>[REDACTED]
[Wed Feb 08 11:52:06.038101 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(164): [client 172.18.0.3:34264] mod_dumpio: dumpio_out
[Wed Feb 08 11:52:06.038141 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (data-HEAP): 146 bytes
[Wed Feb 08 11:52:06.038148 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (data-HEAP): HTTP/1.1 500 Internal server error\r\nDate: Wed, 08 Feb 2023 08:52:04 GMT\r\nServer: Apache/2.4.6 (CentOS)\r\nContent-Length: 189\r\nConnection: close\r\n\r\n
[Wed Feb 08 11:52:06.038161 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(164): [client 172.18.0.3:34264] mod_dumpio: dumpio_out
[Wed Feb 08 11:52:06.038167 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (data-HEAP): 189 bytes
[Wed Feb 08 11:52:06.038173 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(103): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (data-HEAP): {\xd0\x9e\xd0\xb1\xd1\x89\xd0\xb8\xd0\xb9\xd0\x9c\xd0\xbe\xd0\xb4\xd1\x83\xd0\xbb\xd1\x8c.\xd0\x98\xd0\xbd\xd1\x82\xd0\xb5\xd0\xb3\xd1\x80\xd0\xb0\xd1\x86\xd0\xb8\xd1\x8f\xd0\x9c\xd0\xb8\xd0\xba\xd0\xb0\xd1\x80\xd0\xb4.\xd0\x9c\xd0\xbe\xd0\xb4\xd1\x83\xd0\xbb\xd1\x8c(465)}: \xd0\x9f\xd1\x80\xd0\xb5\xd0\xbe\xd0\xb1\xd1\x80\xd0\xb0\xd0\xb7\xd0\xbe\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb8\xd0\xb5 \xd0\xb7\xd0\xbd\xd0\xb0\xd1\x87\xd0\xb5\xd0\xbd\xd0\xb8\xd1\x8f \xd0\xba \xd1\x82\xd0\xb8\xd0\xbf\xd1\x83 \xd0\xa7\xd0\xb8\xd1\x81\xd0\xbb\xd0\xbe \xd0\xbd\xd0\xb5 \xd0\xbc\xd0\xbe\xd0\xb6\xd0\xb5\xd1\x82 \xd0\xb1\xd1\x8b\xd1\x82\xd1\x8c \xd0\xb2\xd1\x8b\xd0\xbf\xd0\xbe\xd0\xbb\xd0\xbd\xd0\xb5\xd0\xbd\xd0\xbe
[Wed Feb 08 11:52:06.038192 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (metadata-EOS): 0 bytes
[Wed Feb 08 11:52:06.038275 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(164): [client 172.18.0.3:34264] mod_dumpio: dumpio_out
[Wed Feb 08 11:52:06.038285 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (metadata-EOR): 0 bytes
[Wed Feb 08 11:52:06.038364 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(164): [client 172.18.0.3:34264] mod_dumpio: dumpio_out
[Wed Feb 08 11:52:06.038371 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (metadata-FLUSH): 0 bytes
[Wed Feb 08 11:52:06.038380 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(164): [client 172.18.0.3:34264] mod_dumpio: dumpio_out
[Wed Feb 08 11:52:06.038386 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (metadata-FLUSH): 0 bytes
[Wed Feb 08 11:52:06.038392 2023] [dumpio:trace7] [pid 25540] mod_dumpio.c(63): [client 172.18.0.3:34264] mod_dumpio:  dumpio_out (metadata-EOC): 0 bytes



Post-processing example:

find /var/tmp/dumpio/ -delete; time ~/projects/miscscripts/bin/dumpio2files.pl /var/tmp/error_log; for infile in $(find /var/tmp/dumpio/ -name in.txt); do indir="$(dirname ${infile})"; sed '1,/^$/d' "${infile}" > "${indir}/payload.xml" && xmllint --xpath '//jpeg_image/text()' "${indir}/payload.xml" | base64 -d > "${indir}/ecg.jpeg"; done

(the request is known to contain XML which in turn has base64-encoded jpeg_image tag).


quick'n'dirty:
< /var/tmp/micard03/var/log/httpd/error_log perl -ne 'next unless /pid 53162/; next unless /data-HEAP/; next if / bytes$/; s,^.*mod_dumpio:\s*,,; $request .= $1 if /dumpio_in .data-HEAP.:\s+(.*)/; $response .= $1 if /dumpio_out .data-HEAP.:\s+(.*)/; END { $request =~ s,\\x?([[:xdigit:]]{2}),chr(hex($1)),eig; $request =~ s,\\n,\n,g; $response =~ s,\\x?([[:xdigit:]]{2}),chr(hex($1)),eig; $response =~ s,\\r\\n,\r\n,g; print $request; print; print $response }' > /var/tmp/ecg.500.example.pid53162.txt


TODO:
    open my $outfiles{$file}, '>>', $file unless $outfiles{$file};
    print $outfiles{$file} $data;
}
map { close } values %outfiles;
