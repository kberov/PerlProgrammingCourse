#!/usr/bin/perl
use strict;
use warnings;
use Net::SMTP;
use Data::Dumper;
my $smtp = Net::SMTP->new(
  Host    => 'localhost',
  Timeout => 30,
  Hello   => 'localhost',
);
my $from = 'berov@bulgarian-creative-circle.org';
my @to   = ('k.berov@gmail.com',);
my $text = $ARGV[0] || 'проба';
my $mess = "ERROR: Can't send mail using Net::SMTP. ";

$smtp->mail($from) || die $mess;
$smtp->to(@to, {SkipBad => 1}) || die $mess;
$smtp->data($text) || die $mess;
$smtp->dataend()   || die $mess;
$smtp->quit();

#print $dumper->Dump([$smtp],['$smtp']);

