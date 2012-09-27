package Data::Table;
BEGIN { die "Your perl version is old, see README for instructions" if $] < 5.005; }

use strict;
use vars qw($VERSION %DEFAULTS @ISA @EXPORT @EXPORT_OK);
use Carp;

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '1.54';
%DEFAULTS = (
  "CSV_DELIMITER"=>',', # controls how to read/write CSV file
  "CSV_QUALIFIER"=>'"',
  "OS"=>0
  # operatoring system: 0 for UNIX (\n as linebreak), 1 for Windows
  # (\r\n as linebreak), 2 for MAC  (\r as linebreak)
  # this controls how to read and write CSV/TSV file
);

sub new {
  my ($pkg, $data, $header, $type, $enforceCheck) = @_;
  my $class = ref($pkg) || $pkg;
  $type = 0 unless defined($type); 
  $header=[] unless defined($header);
  $data=[] unless defined($data);
  $enforceCheck = 1 unless defined($enforceCheck);
  confess "new Data::Table: Size of data does not match header\n"
    if (($type && (scalar @$data) && $#{$data} != $#{$header}) ||
        (!$type && (scalar @$data) && $#{$data->[0]} != $#{$header}));
  my $colHash = checkHeader($header);
  if ($enforceCheck && scalar @$data > 0) {
    my $size=scalar @{$data->[0]};
    for (my $j =1; $j<scalar @$data; $j++) {
      confess "Inconsistent array size at data[$j]" unless (scalar @{$data->[$j]} == $size);
    }
  } elsif (scalar @$data == 0) {
    $type = 0;
  }
  my $self={ data=>$data, header=>$header, type=>$type, colHash=>$colHash};
  return bless $self, $class;
}

sub checkHeader {
  my $header = shift;
  my $colHash = {};
  for (my $i = 0; $i < scalar @$header; $i++) {
    my $elm = $header->[$i];
    confess "Invalid column name (all digits): $elm at column ".($i+1) unless ($elm =~ /\D/);
    confess "Undefined column name (empty or all space) at column ".($i+1) unless $elm;
    #confess "Header name ".$colHash->{$elm}." appears more than once" if defined($colHash->{$elm});
    if (defined($colHash->{$elm})) {
      confess "Header name ($elm) appears more than once: in column ".($colHash->{$elm}+1)." and column ".($i+1).".";
    }
    $colHash->{$elm} = $i;
  }
  return $colHash;
}

# translate a column name into its position in the header
# (also in column-based table)
sub colIndex {
  my ($self, $colID) = @_;
  if ($colID =~ /\D/) {
    my $i = $self->{colHash}->{$colID};
    return -1 unless defined($i);
    return $i;
  }
  return $colID; # assume an index already
}

sub nofCol {
  my $self = shift;
  return scalar @{$self->{header}};
}

sub nofRow {
  my $self = shift;
  return 0 if (scalar @{$self->{data}} == 0);
  return ($self->{type})?
    scalar @{$self->{data}->[0]} : scalar @{$self->{data}};
}

# still need to consider quotes and comma in string
# need to get csv specification
sub csvEscape {
  my ($s, $arg_ref) = @_;
  my ($delimiter, $qualifier) = ($Data::Table::DEFAULTS{CSV_DELIMITER}, $Data::Table::DEFAULTS{CSV_QUALIFIER});
  $delimiter = $arg_ref->{'delimiter'} if (defined($arg_ref) && defined($arg_ref->{'delimiter'}));
  $qualifier = $arg_ref->{'qualifier'} if (defined($arg_ref) && defined($arg_ref->{'qualifier'}));
  return '' unless defined($s);
  my $qualifier2 = $qualifier;
  $qualifier2 = substr($qualifier, 1, 1) if length($qualifier)>1; # in case qualifier is a special symbol for regular expression
  $s =~ s/$qualifier/$qualifier2$qualifier2/g;
  if ($s =~ /[$qualifier$delimiter]/) { return "$qualifier2$s$qualifier2"; }
  return $s;
}

sub tsvEscape {
  my $s = shift;
  my %ESC = ( "\0"=>'0', "\n"=>'n', "\t"=>'t', "\r"=>'r', "\b"=>'b',
              "'"=>"'", "\""=>'"', "\\"=>'\\' );
  ## what about \f? MySQL treats \f as f.
  return "\\N" unless defined($s);
  $s =~ s/([\0\\\b\r\n\t"'])/\\$ESC{$1}/g;
  return $s;
}

# output table in CSV format
sub csv {
  my ($self, $header, $arg_ref)=@_;
  my ($status, @t);
  my $s = '';
  my ($OS, $fileName_or_handler) = ($Data::Table::DEFAULTS{OS}, undef);
  $OS = $arg_ref->{'OS'} if (defined($arg_ref) && defined($arg_ref->{'OS'}));
  my ($delimiter, $qualifier) = ($Data::Table::DEFAULTS{CSV_DELIMITER}, $Data::Table::DEFAULTS{CSV_QUALIFIER});
  if (defined($arg_ref)) {
    $delimiter = $arg_ref->{'delimiter'} if defined($arg_ref->{'delimiter'});
    $qualifier = $arg_ref->{'qualifier'} if defined($arg_ref->{'qualifier'});
    $fileName_or_handler = $arg_ref->{'file'} if defined($arg_ref->{'file'});
  }
  my $delimiter2 = $delimiter; $delimiter2 = substr($delimiter, 1, 1) if length($delimiter)>1;
  my $endl = ($OS==2)?"\r":(($OS==1)?"\r\n":"\n");
  $header=1 unless defined($header);
  $s=join($delimiter2, map {csvEscape($_, {delimiter=>$delimiter, qualifier=>$qualifier})} @{$self->{header}}) . $endl if $header;
######  $self->rotate if $self->{type};
  if ($self->{data}) {
    $self->rotate() if ($self->{type});
    my $data=$self->{data};
    for (my $i=0; $i<=$#{$data}; $i++) {
      $s .= join($delimiter2, map {csvEscape($_, {delimiter=>$delimiter, qualifier=>$qualifier})} @{$data->[$i]}) . $endl;
    }
  }
  if (defined($fileName_or_handler)) {
    my $OUT;
    my $isFileHandler = ref($fileName_or_handler) ne '';
    if ($isFileHandler) {
      $OUT = $fileName_or_handler;
    } else {
      open($OUT, "> $fileName_or_handler") or confess "Cannot open $fileName_or_handler to write.\n";
      binmode $OUT;
    }
    print $OUT $s;
    close($OUT) unless $isFileHandler;
  }
  return $s;
}

# output table in TSV format
sub tsv {
  my ($self, $header, $arg_ref)=@_;
  my ($status, @t);
  my $s = '';
  my ($OS, $fileName_or_handler) = ($Data::Table::DEFAULTS{OS}, undef);
  $OS = $arg_ref->{'OS'} if (defined($arg_ref) && defined($arg_ref->{'OS'}));
  $fileName_or_handler = $arg_ref->{'file'} if (defined($arg_ref) && defined($arg_ref->{'file'}));
  my $endl = ($OS==2)?"\r":(($OS==1)?"\r\n":"\n");
  $header=1 unless defined($header);
  $s=join("\t", map {tsvEscape($_)} @{$self->{header}}) . $endl if $header;
######  $self->rotate if $self->{type};
  if ($self->{data}) {
    $self->rotate() if ($self->{type});
    my $data=$self->{data};
    for (my $i=0; $i<=$#{$data}; $i++) {
      $s .= join("\t", map {tsvEscape($_)} @{$data->[$i]}) . $endl;
    }
  }
  if (defined($fileName_or_handler)) {
    my $OUT;
    my $isFileHandler = ref($fileName_or_handler) ne '';
    if ($isFileHandler) {
      $OUT = $fileName_or_handler;
    } else {
      open($OUT, "> $fileName_or_handler") or confess "Cannot open $fileName_or_handler to write.\n";
      binmode $OUT;
    }
    print $OUT $s;
    close($OUT) unless $isFileHandler;;
  }
  return $s;
}

# output table in HTML format
sub html {
  my ($self, $colors, $tag_tbl, $tag_tr, $tag_th, $tag_td, $portrait) = @_;
  my ($s, $s_tr, $s_td, $s_th) = ("", "tr", "", "th");
  my $key;
  $tag_tbl = { border => 1 } unless (ref $tag_tbl eq 'HASH');
  $tag_tr = {} unless (ref $tag_tr eq 'HASH');
  $tag_th = {} unless (ref $tag_th eq 'HASH');
  $tag_td = {} unless (ref $tag_td eq 'HASH');
  $portrait = 1 unless defined($portrait);

  $s = "<table ";
  foreach $key (keys %$tag_tbl) {
    $s .= " $key=\"$tag_tbl->{$key}\"";
  }
  $s .= ">\n";
  my $header=$self->{header};
  my @BG_COLOR=("#D4D4BF","#ECECE4","#CCCC99");
  @BG_COLOR=@$colors if ((ref($colors) eq "ARRAY") && (scalar @$colors==3));
  foreach $key (keys %$tag_tr) {
    $s_tr .= " $key=\"$tag_tr->{$key}\"";
  }
  foreach $key (keys %$tag_th) {
    $s_th .= " $key=\"$tag_th->{$key}\"";
  }
  if ($portrait) {
    $s .= "<$s_tr bgcolor=\"" . $BG_COLOR[2] . "\"><$s_th>" .
      join("</th><$s_th>", @$header) . "</th></tr>\n";
    $self->rotate() if $self->{type};
    my $data=$self->{data};
    for (my $i=0; $i<=$#{$data}; $i++) {
      $s .= "<$s_tr bgcolor=\"" . $BG_COLOR[$i%2] . "\">";
      for (my $j=0; $j<=$#{$header}; $j++) {
        my $s_td = $tag_td->{$j} || $tag_td->{$header->[$j]};
        $s .= defined($s_td)? "<td $s_td>":"<td>";
        $s .= (defined($data->[$i][$j]) && $data->[$i][$j] ne '')?$data->[$i][$j]:"&nbsp;";
        $s .= "</td>";
      }
      $s .= "</tr>\n";
    }
  } else {
    $self->rotate() unless $self->{type};
    my $data=$self->{data};
    for (my $i = 0; $i <= $#{$header}; $i++) {
      $s .= "<$s_tr><$s_th bgcolor=\"" . $BG_COLOR[2] . "\">" .
            $header->[$i] . "</th>";
      my $s_td = $tag_td->{$i} || $tag_td->{$header->[$i]};
      for (my $j=0; $j<=$#{$data->[0]}; $j++) {
        $s .= defined($s_td)? "<td $s_td":"<td";
        $s .= " bgcolor=\"" . $BG_COLOR[$j%2] . "\">";
        $s .= (defined($data->[$i][$j]) && $data->[$i][$j] ne '')?$data->[$i][$j]:'&nbsp;';
        $s .= "</td>";
      }
      $s .= "</tr>\n";
    }
  }
  $s .= "</table>\n";
  return $s;
}

# output table in HTML format, with table orientation rotated,
# so that each HTML table row is a column in the table
# This is useful for a slim table (few columns but many rows)
sub html2 {
  my ($self, $colors, $tag_tbl, $tag_tr, $tag_th, $tag_td) = @_;
  return $self->html($colors, $tag_tbl, $tag_tr, $tag_th, $tag_td, 0);
}

# apply a $fun to each elm in a col 
# function only has access to one element per row
sub colMap {
  my ($self, $colID, $fun) = @_;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  $self->rotate() unless $self->{type};
  my $ref = $self->{data}->[$c];
  my @tmp = map {scalar $fun->($_)} @$ref;
  $self->{data}->[$c] = \@tmp;
  return 1;
} 

# apply a $fun to each row in the table
# function has access to all elements in that row
sub colsMap {
  my ($self, $fun) = @_;
  $self->rotate() if $self->{type};
  map {&$fun} @{$self->{data}};
  return 1;
}

sub addRow {
  my ($self, $rowRef, $rowIdx) = @_;
  my $numRow=$self->nofRow();
  my @t;
  confess "addRow: size of added row does not match those in the table\n"
	if scalar @$rowRef != $self->nofCol();
  $rowIdx=$numRow unless defined($rowIdx);
  return undef unless defined $self->checkNewRow($rowIdx);
  $self->rotate() if $self->{type};
  my $data=$self->{data};
  if ($rowIdx == 0) {
    unshift @$data, $rowRef;
  } elsif ($rowIdx == $numRow) {
    push @$data, $rowRef;
   } else {
    @t = splice @$data, $rowIdx;
    push @$data, $rowRef, @t;
  }
  return 1;
}

sub delRow {
  my ($self, $rowIdx ) = @_;
  return undef unless defined $self->checkOldRow($rowIdx);
  $self->rotate() if $self->{type};
  my $data=$self->{data};
  my @dels=splice(@$data, $rowIdx, 1);
  return shift @dels;
}                                                                               

sub delRows {
  my ($self, $rowIdcsRef) = @_;
  my $rowIdx;
  my @indices = sort { $b <=> $a } @$rowIdcsRef;
  my @dels=();
  foreach $rowIdx (@indices) {
    push @dels, $self->delRow($rowIdx);
  }
  return @dels;
}   

# append a column to the table, input is a referenceof_array

sub addCol {
  my ($self, $colRef, $colName, $colIdx) = @_;
  my $numCol=$self->nofCol();
  my @t;
  confess "addCol: size of added col does not match rows in the table\n" 
	if scalar @$colRef != $self->nofRow(); 
  $colIdx=$numCol unless defined($colIdx);
  return undef unless defined $self->checkNewCol($colIdx, $colName);
  $self->rotate() unless $self->{type};
  my $data=$self->{data};
  my $header=$self->{header};
  if ($colIdx == 0) {
    unshift @$header, $colName;
  } elsif ($colIdx == $numCol) {
    push @$header, $colName;
  } else {
    @t = splice @$header, $colIdx;
    push @$header, $colName, @t;
  }

  if ($colIdx == 0) {
    unshift @$data, $colRef;
  } elsif ($colIdx == $numCol) {
    push @$data, $colRef;
  } else {
    @t = splice @$data, $colIdx;
    push @$data, $colRef, @t;
  }

  for (my $i = 0; $i < scalar @$header; $i++) {
    my $elm = $header->[$i];
    $self->{colHash}->{$elm} = $i;
  }
  return 1;
}

sub delCol {
  my ($self, $colID) = @_;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  my $header=$self->{header};
  my $name=$self->{header}->[$c];
  splice @$header, $c, 1;
  $self->rotate() unless $self->{type};
  my $data=$self->{data};
  delete $self->{colHash}->{$name};
  for (my $i = 0; $i < scalar @$header; $i++) {
    my $elm = $header->[$i];
    $self->{colHash}->{$elm} = $i;
  }
  my @dels=splice @$data, $c, 1;
  return shift @dels;
}                                                                               

sub delCols {
  my ($self, $colIDsRef) = @_;
  my $idx;
  my @indices = map { $self->colIndex($_) } @$colIDsRef;
  @indices = sort { $b <=> $a } @indices;

  my @dels=();
  foreach my $colIdx (@indices) {
    push @dels, $self->delCol($colIdx);
  }
  return @dels;
}  


sub rowRef {
  my ($self, $rowIdx) = @_;
  return undef unless defined $self->checkOldRow($rowIdx);
  $self->rotate if $self->{type};
  return $self->{data}->[$rowIdx];
}

sub rowRefs {
  my ($self, $rowIdcsRef) = @_;
  $self->rotate if $self->{type};
  return $self->{data} unless defined $rowIdcsRef;
  my @ones = ();
  my $rowIdx;
  foreach $rowIdx (@$rowIdcsRef) {
    push @ones, $self->rowRef($rowIdx);
  }
  return \@ones;
}

sub row {
  my ($self, $rowIdx) = @_;
  my $data = $self->{data};
  return undef unless defined $self->checkOldRow($rowIdx);
  if ($self->{type}) {
    my @one=(); 
    for (my $i = 0; $i < scalar @$data; $i++) {
      push @one, $data->[$i]->[$rowIdx];
    }
    return @one;
  } else {
    return @{$data->[$rowIdx]};
  }
}

sub rowHashRef {
  my ($self, $rowIdx) = @_;
  my $data = $self->{data};
  return undef unless defined $self->checkOldRow($rowIdx);
  my $header=$self->{header};
  my $one = {};
  for (my $i = 0; $i < scalar @$header; $i++) {
    $one->{$header->[$i]} = ($self->{type})?
      $self->{data}->[$i]->[$rowIdx]:$self->{data}->[$rowIdx]->[$i];
  }
  return $one;
}

sub colRef {
  my ($self, $colID) = @_;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  $self->rotate() unless $self->{type};
  return $self->{data}->[$c];
}

sub colRefs {
  my ($self, $colIDsRef) = @_;
  $self->rotate unless $self->{type};
  return $self->{data} unless defined $colIDsRef;
  my @ones = ();
  my $colID;
  foreach $colID (@$colIDsRef) {
    push @ones, $self->colRef($colID);
  }
  return \@ones;
}

sub col {
  my ($self, $colID) = @_;
  my $data = $self->{data};
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  if (!$self->{type}) {
    my @one=();
    for (my $i = 0; $i < scalar @$data; $i++) {
      push @one, $data->[$i]->[$c];
    }
    return @one;
  } else {
    return () unless ref($data->[$c]) eq "ARRAY";
    return @{$data->[$c]};
  }
}

sub rename {
  my ($self, $colID, $name) = @_;
  my $oldName;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  $oldName=$self->{header}->[$c];
  return if ($oldName eq $name);
  return undef unless defined $self->checkNewCol($c, $name);
  $self->{header}->[$c]=$name;
  $self->{colHash}->{$oldName}=undef;
  $self->{colHash}->{$name}=$c;
  return 1;
}

sub replace{
  my ($self, $oldColID, $newColRef, $newName) = @_;
  my $oldName;
  my $c=$self->checkOldCol($oldColID);
  return undef unless defined $c;
  $oldName=$self->{header}->[$c];
  $newName=$oldName unless defined($newName);
  unless ($oldName eq $newName) {
  	return undef unless defined $self->checkNewCol($c, $newName);
  }
  confess "New column size ".(scalar @$newColRef)." must be ".$self->nofRow() unless (scalar @$newColRef==$self->nofRow());
  $self->rename($c, $newName);
  $self->rotate() unless $self->{type};
  my $old=$self->{data}->[$c];
  $self->{data}->[$c]=$newColRef;
  return $old;
}

sub swap{
  my ($self, $colID1, $colID2) = @_;
  my $c1=$self->checkOldCol($colID1);
  return undef unless defined $c1;
  my $c2=$self->checkOldCol($colID2);
  return undef unless defined $c2;
  my $name1=$self->{header}->[$c1];
  my $name2=$self->{header}->[$c2];

  $self->{header}->[$c1]=$name2;
  $self->{header}->[$c2]=$name1;
  $self->{colHash}->{$name1}=$c2;
  $self->{colHash}->{$name2}=$c1;
  $self->rotate() unless $self->{type};
  my $data1=$self->{data}->[$c1];
  my $data2=$self->{data}->[$c2];
  $self->{data}->[$c1]=$data2;
  $self->{data}->[$c2]=$data1;
  return 1;
}

sub checkOldRow {
  my ($self, $rowIdx) = @_;
  my $maxIdx=$self->nofRow()-1;
  unless (defined $rowIdx) {
	print STDERR " Invalid row index\n";
	return undef;
  }
  if ($rowIdx<0 || $rowIdx>$maxIdx) {
	print STDERR  "Row index out of range [0..$maxIdx]" ;
	return undef;
  }
  return $rowIdx;
}

sub checkNewRow {
  my ($self, $rowIdx) = @_;
  my $maxIdx=$self->nofRow()-1;
  unless (defined $rowIdx) {
	print STDERR "Invalid row index: $rowIdx \n";
	return undef;
  } 
  $maxIdx+=1;
  if ($rowIdx<0 || $rowIdx>$maxIdx) {
  	print STDERR  "Row index out of range [0..$maxIdx]" ;
	return undef;
  }
  return $rowIdx;
}

sub checkOldCol {
  my ($self, $colID) = @_;
  my $c=$self->colIndex($colID);
  if ($c < 0) {
  	print STDERR "Invalid column $colID";
	return undef;
  } 
  return $c;
}

sub checkNewCol {
  my ($self, $colIdx, $colName) = @_;
  my $numCol=$self->nofCol();
  unless (defined $colIdx) { 
      	print STDERR "Invalid column index $colIdx";
      	return undef;
  }	
  if ($colIdx<0 || $colIdx>$numCol) {
      	print STDERR "Column index $colIdx out of range [0..$numCol]";
  	return undef;
  }	
  if (defined $self->{colHash}->{$colName} ) {
	print STDERR "Column name $colName already exists" ;
	return undef;
  }
  unless ($colName =~ /\D/) { 
    	print STDERR "Invalid column name $colName" ;
	return undef;
  }
  return $colIdx;
}

sub elm {
  my ($self, $rowIdx, $colID) = @_;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  return undef unless defined $self->checkOldRow($rowIdx);
  return ($self->{type})?
    $self->{data}->[$c]->[$rowIdx]:
    $self->{data}->[$rowIdx]->[$c];
}

sub elmRef {
  my ($self, $rowIdx, $colID) = @_;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  return undef unless defined $self->checkOldRow($rowIdx);
  return ($self->{type})?
    \$self->{data}->[$c]->[$rowIdx]:
    \$self->{data}->[$rowIdx]->[$c];
}

sub setElm {
  my ($self, $rowIdx, $colID, $val) = @_;
  my $c=$self->checkOldCol($colID);
  return undef unless defined $c;
  return undef unless defined $self->checkOldRow($rowIdx);
  if ($self->{type}) {
    $self->{data}->[$c]->[$rowIdx]=$val;
  } else {
    $self->{data}->[$rowIdx]->[$c]=$val;
  }
  return 1;
}

# convert the internal structure of a table between row-based and column-based
sub rotate {
  my $self=shift;
  my $newdata=[];
  my $data=$self->{data};
  $self->{type} = ($self->{type})?0:1;
  if ($self->{type} && scalar @$data == 0) {
    for (my $i=0; $i < $self->nofCol; $i++) {
      $newdata->[$i] = [];
    }
  } else {
    for (my $i=$#{$data->[0]}; $i>=0; $i--) {
      for (my $j=$#{$data}; $j>=0;  $j--) {
        $newdata->[$i][$j]=$data->[$j][$i];
      }
    }
  }
  $self->{data}=$newdata;
  return 1;
}

sub header {
  my ($self, $header) = @_;
  unless (defined($header)) {
    return @{$self->{header}};
  } else {
    if (scalar @$header != scalar @{$self->{header}}) {
      confess "Header array should have size ".(scalar @{$self->{header}});
    } else {
      my $colHash = checkHeader($header);
      $self->{header} = $header;
      $self->{colHash} = $colHash;
    }
  }
}

sub type {
  my $self=shift;
  return $self->{type};
}

sub data {
  my $self=shift;
  return $self->{data};
}

#  $t->sort(colID1, type1, order1, colID2, type2, order2, ... );
#  where
#    colID is a column index (integer) or name (string),
#    type is 0 for numerical and 1 for others
#    order is 0 for ascending and 1 for descending
#    Sorting is done with priority of colname1, colname2, ...

sub sort_v0 {
  my $self = shift;
  my ($str, $i) = ("", 0);
  my @cols = ();
  while (scalar @_) {
    my $c = shift;
    my $col = $self->checkOldCol($c);
    return undef unless defined $col;
    push @cols, $col;
    my $op = '<=>';
    $op = 'cmp' if shift;  				# string 
    $str .=(shift)?  "(\$b->[$i] $op \$a->[$i]) || " :
      "(\$a->[$i] $op \$b->[$i]) || " ;
    $i++;
  }
  substr($str, -3) = "";  	# removes ||  from the end of $str
  $self->rotate() if $self->{type};
  # construct a pre-ordered array
  my $fun = sub { my ($cols, $data) = @_;
  		  my @ext;
  		  @ext = map {$data->[$_]} @$cols;
  		  push @ext, $data;
  		  return \@ext;
		};
  my @preordered = map {&$fun(\@cols, $_)} @{$self->{data}};
  $self->{data} = [ map {$_->[$i]} eval "sort {$str} \@preordered;" ];
  return 1;
} 
  
sub sort {
    my $self = shift;
    my @cols = @_;
    confess "Parameters be in groups of three!\n" if ($#cols % 3 != 2);
    foreach (0 .. ($#cols/3)) {
      my $col = $self->checkOldCol($cols[$_*3]);
      return undef unless defined $col;
      $cols[$_*3]=$col;
    }
    my @subs=();
    for (my $i=0; $i<=$#cols; $i+=3) {
      my $mysub;
      if ($cols[$i+1] == 0) {
        $mysub = ($cols[$i+2]? sub {defined($_[1])?(defined($_[0])? $_[1] <=> $_[0]:1):(defined($_[0])?-1:0)} : sub {defined($_[1])?(defined($_[0])? $_[0] <=> $_[1]:-1):(defined($_[0])?1:0)});
      } elsif ($cols[$i+1] == 1) {
        $mysub = ($cols[$i+2]? sub {defined($_[1])?(defined($_[0])? $_[1] cmp $_[0]:1):(defined($_[0])?-1:0)} : sub {defined($_[1])?(defined($_[0])? $_[0] cmp $_[1]:-1):(defined($_[0])?1:0)});
      } elsif (ref $cols[$i+1] eq 'CODE') {
        my $predicate=$cols[$i+1];
        $mysub = ($cols[$i+2]? sub {defined($_[1])?(defined($_[0])? $predicate->($_[1],$_[0]) : 1): (defined($_[0])?-1:0)} : 
                               sub {defined($_[1])?(defined($_[0])? $predicate->($_[0],$_[1]) : -1): (defined($_[0])?1:0)} );
      } else {
        confess "Sort method should be 0 (numerical), 1 (other type), or a subroutine reference!\n";
      }
      push @subs, $mysub;
    }
    my $func = sub {
      my $res = 0;
      foreach (0 .. ($#cols/3)) {
        $res ||= $subs[$_]->($a->[$cols[$_*3]], $b->[$cols[$_*3]]);
        return $res unless $res==0;
      }
      return $res;
    };
    $self->rotate() if $self->{type};
    $self->{data} = [sort $func @{$self->{data}}];
    return 1;
}

# return rows as sub table in which
# a pattern $pattern is matched 
sub match_pattern {
  my ($self, $pattern, $countOnly) = @_;
  my @data=();
  $countOnly=0 unless defined($countOnly);
  my $cnt=0;
  $self->rotate() if $self->{type};
  @Data::Table::OK= eval "map { $pattern?1:0; } \@{\$self->{data}};";
  for (my $i=0; $i<$self->nofRow(); $i++) {
    if ($Data::Table::OK[$i]) {
      push @data, $self->{data}->[$i] unless $countOnly;
      $cnt++;
    }
  }
  return $cnt if $countOnly;
  my @header=@{$self->{header}};
  return new Data::Table(\@data, \@header, 0);
}

# return rows as sub table in which 
# a string elm in an array @$s is matched 
sub match_string {
  my ($self, $s, $caseIgn, $countOnly) = @_;
  confess unless defined($s);
  $countOnly=0 unless defined($countOnly);
  my @data=();
  my $r;
  $self->rotate() if $self->{type};
  @Data::Table::OK=();
  $caseIgn=0 unless defined($caseIgn);

  ### comment out next line if your perl version < 5.005 ###
  $r = ($caseIgn)?qr/$s/i : qr/$s/;
  my $cnt=0;

  foreach my $row_ref (@{$self->data}) {
    push @Data::Table::OK, undef;
    foreach my $elm (@$row_ref) {
        next unless defined($elm);
        
        ### comment out the next line if your perl version < 5.005
        if ($elm =~ /$r/) {
        ### uncomment the next line if your perl version < 5.005
	# if ($elm =~ /$s/ || ($elm=~ /$s/i && $caseIgn)) {

		push @data, $row_ref unless $countOnly;
		$Data::Table::OK[$#Data::Table::OK]=1;
                $cnt++;
		last;
   	}
    }
  }
  return $cnt if $countOnly;
  my @header=@{$self->{header}};
  return new Data::Table(\@data, \@header, 0);
}
	
sub rowMask {
  my ($self, $OK, $c) = @_;
  confess unless defined($OK);
  $c = 0 unless defined ($c);
  my @data=();
  $self->rotate() if $self->{type};
  my $data0=$self->data;
  for (my $i=0; $i<$self->nofRow(); $i++) {
    if ($c) {
      push @data, $data0->[$i] unless $OK->[$i];
    } else {
      push @data, $data0->[$i] if $OK->[$i];
    }
  }
  my @header=@{$self->{header}};
  return new Data::Table(\@data, \@header, 0);
}

sub rowMerge {
  my ($self, $tbl) = @_;
  confess "Tables must have the same number of columns" unless ($self->nofCol()==$tbl->nofCol());
  $self->rotate() if $self->{type};
  $tbl->rotate() if $tbl->{type};
  my $data=$self->{data};
#  for ($i=0; $i<$tbl->nofRow(); $i++) {
  push @$data, @{$tbl->{data}};
#  }
  return 1;
}

sub colMerge {
  my ($self, $tbl) = @_;
  confess "Tables must have the same number of rows" unless ($self->nofRow()==$tbl->nofRow());
  my $col;
  foreach $col ($tbl->header) {
    confess "Duplicate column $col in two tables" if defined($self->{colHash}->{$col});
  }
  my $i = $self->nofCol();
  foreach $col ($tbl->header) {
    push @{$self->{header}}, $col;
    $self->{colHash}->{$col} = $i++; 
  }
  $self->rotate() unless $self->{type};
  $tbl->rotate() unless $tbl->{type};
  my $data=$self->{data};
  for ($i=0; $i<$tbl->nofCol(); $i++) {
    push @$data, $tbl->{data}->[$i];
  }
  return 1;
}

sub subTable {
  my ($self, $rowIdcsRef, $colIDsRef) = @_;
  my @newdata=();
  my @newheader=();
  $rowIdcsRef = [0..($self->nofRow()-1)] unless defined $rowIdcsRef;
  $colIDsRef = [0..($self->nofCol()-1)] unless defined $colIDsRef; 
  for (my $i = 0; $i < scalar @{$colIDsRef}; $i++) {
    $colIDsRef->[$i]=$self->checkOldCol($colIDsRef->[$i]);
    return undef unless defined $colIDsRef;
    push @newheader, $self->{header}->[$colIDsRef->[$i]];
  }
  if ($self->{type}) {
    for (my $i = 0; $i < scalar @{$colIDsRef}; $i++) {
      my @one=();
      for (my $j = 0; $j < scalar @{$rowIdcsRef}; $j++) {
	return undef unless defined $self->checkOldRow($rowIdcsRef->[$j]);
        push @one, $self->{data}->[$colIDsRef->[$i]]->[$rowIdcsRef->[$j]];
      }
      push @newdata, \@one;
    }
  } else {
    for (my $i = 0; $i < scalar @{$rowIdcsRef}; $i++) {
      return undef unless defined $self->checkOldRow($rowIdcsRef->[$i]);	
      my @one=();
      for (my $j = 0; $j < scalar @{$colIDsRef}; $j++) {
        push @one, $self->{data}->[$rowIdcsRef->[$i]]->[$colIDsRef->[$j]];
      }
      push @newdata, \@one;
    }
  }
  return new Data::Table(\@newdata, \@newheader, $self->{type});
}

sub clone {
  my $self = shift;
  my $data = $self->{data};
  my @newheader = @{$self->{header}};
  my @newdata = ();
  for (my $i = 0; $i < scalar @{$data}; $i++) {
    my @one=();
    for (my $j = 0; $j < scalar @{$data->[$i]}; $j++) {
      push @one, $data->[$i]->[$j];
    }
    push @newdata, \@one;
  }
  return new Data::Table(\@newdata, \@newheader, $self->{type});
}

sub fromCSVi {
  my $self = shift;
  return fromCSV(@_);
}

sub fromCSV {
  my ($name_or_handler, $includeHeader, $header, $arg_ref) = @_;
  $includeHeader = 1 unless defined($includeHeader);
  my ($OS, $delimiter, $qualifier, $skip_lines, $skip_pattern) = ($Data::Table::DEFAULTS{OS}, $Data::Table::DEFAULTS{CSV_DELIMITER}, $Data::Table::DEFAULTS{CSV_QUALIFIER}, 0, undef);
  $OS = $arg_ref->{'OS'} if (defined($arg_ref) && defined($arg_ref->{'OS'}));
  # OS: 0 for UNIX (\n as linebreak), 1 for Windows (\r\n as linebreak)
  ###   2 for MAC  (\r as linebreak)
  if (defined($arg_ref)) {
    $delimiter = $arg_ref->{'delimiter'} if defined($arg_ref->{'delimiter'});
    $qualifier = $arg_ref->{'qualifier'} if defined($arg_ref->{'qualifier'});
    $skip_lines = $arg_ref->{'skip_lines'} if (defined($arg_ref->{'skip_lines'}) && $arg_ref->{'skip_lines'}>0);
    $skip_pattern = $arg_ref->{'skip_pattern'} if defined($arg_ref->{'skip_pattern'});
  }
  my @header;
  my $givenHeader = 0;
  if (defined($header) && ref($header) eq 'ARRAY') {
    $givenHeader = 1;
    @header= @$header;
  }
  my $isFileHandler=ref($name_or_handler) ne "";
  my $SRC;
  if ($isFileHandler) {
    $SRC = $name_or_handler; # a file handler
  } else {
    open($SRC, $name_or_handler) or confess "Cannot open $name_or_handler to read";
    binmode $SRC,':utf8';#TODO:Send a Bug-report/feature request with patch
  }
  my @data = ();
  my $oldRowDelimiter=$/;
  my $newRowDelimiter=($OS==2)?"\r":(($OS==1)?"\r\n":"\n");
  my $n_endl = length($newRowDelimiter);
  $/=$newRowDelimiter;
  my $s;
  for (my $i=0; $i<$skip_lines; $i++) {
    $s=<$SRC>;
  }
  $s=<$SRC>;
  if (defined($skip_pattern)) { while (defined($s) && $s =~ /$skip_pattern/) { $s = <$SRC> }; }
  if (substr($s, -$n_endl, $n_endl) eq $newRowDelimiter) { for (1..$n_endl) { chop $s }}
  # $_=~ s/$newRowDelimiter$//;
  unless ($s) {
    #confess "Empty data file" unless $givenHeader;
    return undef unless $givenHeader;
    $/=$oldRowDelimiter;
    return new Data::Table(\@data, \@header, 0);
  }
  my $one;
  if ($s =~ /$delimiter$/) { # if the line ends by ',', the size of @one will be incorrect
              # due to the tailing of split function in perl
    $s .= ' '; # e.g., split $s="a," will only return a list of size 1.
    $one = parseCSV($s, undef, {delimiter=>$delimiter, qualifier=>$qualifier});
    $one->[$#{@$one}]=undef;
  } else {
    $one = parseCSV($s, undef, {delimiter=>$delimiter, qualifier=>$qualifier});
  }
  #print join("|", @$one), scalar @$one, "\n";
  my $size = scalar @$one;
  unless ($givenHeader) {
    if ($includeHeader) {
      @header = @$one;
    } else {
      @header = map {"col$_"} (1..$size); # name each column as col1, col2, .. etc
    }
  }
  push @data, $one unless ($includeHeader);

  while($s = <$SRC>) {
    next if (defined($skip_pattern) && $s =~ /$skip_pattern/);
    if (substr($s, -$n_endl, $n_endl) eq $newRowDelimiter) { for (1..$n_endl) { chop $s }}
    # $_=~ s/$newDelimiter$//;
    my $one = parseCSV($s, $size, {delimiter=>$delimiter, qualifier=>$qualifier});
    confess "Inconsistent column number at data entry: ".($#data+1) unless ($size==scalar @$one);
    push @data, $one;
  }
  close($SRC) unless $isFileHandler;
  $/=$oldRowDelimiter;
  return new Data::Table(\@data, \@header, 0);
}

# Idea: use \ as the escape char to encode a CSV string,
# replace \ by \\ and comma inside a field by \c.
# A comma inside a field must have odd number of " in front of it,
# therefore it can be distinguished from comma used as the deliminator.
# After escape, and split by comma, we unescape each field string.
#
# This parser will never be crashed by any illegal CSV format,
# it always return an array!
sub parseCSV {
  my ($s, $size, $arg_ref)=@_;
  $size = 0 unless defined $size;
  my ($delimiter, $qualifier) = ($Data::Table::DEFAULTS{CSV_DELIMITER}, $Data::Table::DEFAULTS{CSV_QUALIFIER});
  $delimiter = $arg_ref->{'delimiter'} if (defined($arg_ref) && defined($arg_ref->{'delimiter'}));
  $qualifier = $arg_ref->{'qualifier'} if (defined($arg_ref) && defined($arg_ref->{'qualifier'}));
  my $delimiter2 = $delimiter; $delimiter2 = substr($delimiter, 1, 1) if length($delimiter)>1;
  my $qualifier2 = $qualifier; $qualifier2 = substr($qualifier, 1, 1) if length($qualifier)>1;
  # $s =~ s/\n$//; # chop" # assume extra characters has been cleaned before
  return [split /$delimiter/, $s , $size] if -1==index $s, $qualifier;
  $s =~ s/\\/\\\\/g; # escape \ => \\
  my $n = length($s);
  my ($q, $i)=(0, 0);
  while ($i < $n) {
    my $ch=substr($s, $i, 1);
    $i++;
    if ($ch eq $delimiter2 && ($q%2)) {
      substr($s, $i-1, 1)='\\c'; # escape , => \c if it's not a deliminator
      $i++;
      $n++;
    } elsif ($ch eq $qualifier2) {
      $q++;
    }
  }
  $s =~ s/(^$qualifier)|($qualifier\s*$)//g; # get rid of boundary ", then restore "" => "
  $s =~ s/$qualifier\s*$delimiter/$delimiter2/g;
  $s =~ s/$delimiter\s*$qualifier/$delimiter2/g;
  $s =~ s/$qualifier$qualifier/$qualifier2/g;
  my @parts=split(/$delimiter/, $s, $size);
  @parts = map {$_ =~ s/(\\c|\\\\)/$1 eq '\c'?$delimiter2:'\\'/eg; $_ } @parts;
#  my @parts2=();
#  foreach $s2 (@parts) {
#    $s2 =~ s/\\c/,/g;   # restore \c => ,
#    $s2 =~ s/\\\\/\\/g; # restore \\ => \
#    push @parts2, $s2;
#  }
  return \@parts;
}

sub fromTSVi {
  my $self = shift;
  return fromTSV(@_);
}

sub fromTSV {
  my ($name_or_handler, $includeHeader, $header, $arg_ref) = @_;
  my ($OS, $skip_lines, $skip_pattern) = ($Data::Table::DEFAULTS{OS}, 0, undef);
  $OS = $arg_ref->{'OS'} if (defined($arg_ref) && defined($arg_ref->{'OS'}));
  # OS: 0 for UNIX (\n as linebreak), 1 for Windows (\r\n as linebreak)
  ###   2 for MAC  (\r as linebreak)
  $skip_lines = $arg_ref->{'skip_lines'} if (defined($arg_ref) && defined($arg_ref->{'skip_lines'}) && $arg_ref->{'skip_lines'}>0);
  $skip_pattern = $arg_ref->{'skip_pattern'} if defined($arg_ref->{'skip_pattern'});
 
  my %ESC = ( '0'=>"\0", 'n'=>"\n", 't'=>"\t", 'r'=>"\r", 'b'=>"\b",
              "'"=>"'", '"'=>"\"", '\\'=>"\\" );
  ## what about \f? MySQL treats \f as f.

  $includeHeader = 1 unless defined($includeHeader);
  $OS=0 unless defined($OS);
 
  my @header;
  my $givenHeader = 0;
  if (defined($header) && ref($header) eq 'ARRAY') {
    $givenHeader = 1;
    @header= @$header;
  }
  my $isFileHandler=ref($name_or_handler) ne "";
  my $SRC;
  if ($isFileHandler) {
    $SRC = $name_or_handler; # a file handler
  } else {
    open($SRC, $name_or_handler) or confess "Cannot open $name_or_handler to read";
    binmode $SRC;
  }
  my @data = ();
  my $oldRowDelimiter=$/;
  my $newRowDelimiter=($OS==2)?"\r":(($OS==1)?"\r\n":"\n");
  my $n_endl = length($newRowDelimiter);
  $/=$newRowDelimiter;
  my $s;
  for (my $i=0; $i<$skip_lines; $i++) {
    $s=<$SRC>;
  }
  $s=<$SRC>;
  if (defined($skip_pattern)) { while (defined($s) && $s =~ /$skip_pattern/) { $s = <$SRC> }; }
  if (substr($s, -$n_endl, $n_endl) eq $newRowDelimiter) { for (1..$n_endl) { chop $s }}
  # $_=~ s/$newRowDelimiter$//;
  unless ($s) {
    confess "Empty data file" unless $givenHeader;
    $/=$oldRowDelimiter;
    return new Data::Table(\@data, \@header, 0);
  }
  #chop;
  my $one;
  if ($s =~ /\t$/) { # if the line ends by ',', the size of @$one will be incorrect
              # due to the tailing of split function in perl
    $s .= ' '; # e.g., split $s="a," will only return a list of size 1.
    @$one = split(/\t/, $s);
    $one->[$#{@$one}]='';
  } else {
    @$one = split(/\t/, $s);
  }
  # print join("|", @$one), scalar @$one, "\n";
  my $size = scalar @$one;
  unless ($givenHeader) {
    if ($includeHeader) {
      @header = map { $_ =~ s/\\([0ntrb'"\\])/$ESC{$1}/g; $_ } @$one;
    } else {
      @header = map {"col$_"} (1..$size); # name each column as col1, col2, .. etc
    }
  }
  push @data, $one unless ($includeHeader);

  while($s = <$SRC>) {
    #chop;
    # $_=~ s/$newRowDelimiter$//;
    next if (defined($skip_pattern) && $s =~ /$skip_pattern/);
    if (substr($s, -$n_endl, $n_endl) eq $newRowDelimiter) { for (1..$n_endl) { chop $s }}
    my @one = split(/\t/, $s, $size);
    for (my $i=0; $i < $size; $i++) {
      next unless defined($one[$i]);
      if ($one[$i] eq "\\N") {
        $one[$i]=undef;
      } else {
        $one[$i] =~ s/\\([0ntrb'"\\])/$ESC{$1}/g;
      }
    }
    confess "Inconsistent column number at data entry: ".($#data+1) unless ($size==scalar @one);
    push @data, \@one;
  }
  close($SRC) unless $isFileHandler;
  $/=$oldRowDelimiter;
  return new Data::Table(\@data, \@header, 0);
}

sub fromSQLi {
  my $self = shift;
  return fromSQL(@_);
}

sub fromSQL {
  my ($dbh, $sql, $vars) = @_;
  my ($sth, $header, $t);
  $sth = $dbh->prepare($sql) or confess "Preparing: , ".$dbh->errstr;
  my @vars=() unless defined $vars;
  $sth->execute(@$vars) or confess "Executing: ".$dbh->errstr;
#  $Data::Table::ID = undef;
#  $Data::Table::ID = $sth->{'mysql_insertid'};
  if ($sth->{NUM_OF_FIELDS}) {
    $header=$sth->{'NAME'};
    $t = new Data::Table($sth->fetchall_arrayref(), $header, 0);
  } else {
    $t = undef;
  }
  $sth->finish;
  return $t;
}

sub join {
  my ($self, $tbl, $type, $cols1, $cols2) = @_;
  my $n1 = scalar @$cols1;
  # default cols2 to cols1 if not specified
  if (!defined($cols2) && $n1>0) {
    $cols2 = [];
    foreach my $c (@$cols1) {
      push @$cols2, $c;
    }
  }
  my $n2 = scalar @$cols2;
  confess "The number of join columns must be the same: $n1 != $n2" unless $n1==$n2;
  confess "At least one join column must be specified" unless $n1;
  my ($i, $j, $k);
  my @cols3 = ();
  for ($i = 0; $i < $n1; $i++) {
    $cols1->[$i]=$self->checkOldCol($cols1->[$i]);
    confess "Unknown column ". $cols1->[$i] unless defined($cols1->[$i]);
    $cols2->[$i]=$tbl->checkOldCol($cols2->[$i]);
    confess "Unknown column ". $cols2->[$i] unless defined($cols2->[$i]);
    $cols3[$cols2->[$i]]=1;
  }
  my @cols4 = (); # the list of remaining columns
  my @header2 = ();
  for ($i = 0; $i < $tbl->nofCol; $i++) {
    unless (defined($cols3[$i])) {
      push @cols4, $i;
      push @header2, $tbl->{header}->[$i];
    }
  }

  $self->rotate() if $self->{type};
  $tbl->rotate() if $tbl->{type};
  my $data1 = $self->{data};
  my $data2 = $tbl->{data};
  my %H=();
  my $key;
  my @subRow;
  for ($i = 0; $i < $self->nofRow; $i++) {
    @subRow = @{$data1->[$i]}[@$cols1];
    $key = join("\t", map {tsvEscape($_)} @subRow);
    unless (defined($H{$key})) {
      $H{$key} = [[$i], []];
    } else {
      push @{$H{$key}->[0]}, $i;
    }
  }
  for ($i = 0; $i < $tbl->nofRow; $i++) {
    @subRow = @{$data2->[$i]}[@$cols2];
    $key = join("\t", map {tsvEscape($_)} @subRow);
    unless (defined($H{$key})) {
      $H{$key} = [[], [$i]];
    } else {
      push @{$H{$key}->[1]}, $i;
    }
  }
# $type
# 0: inner join
# 1: left outer join
# 2: right outer join
# 3: full outer join
  my @ones = ();
  my @null1 = ();
  my @null2 = ();
  my @null3 = ();
  $null1[$self->nofCol-1]=undef;
  $null3[$self->nofCol-1]=undef;
  if ($#cols4>=0) { $null2[$#cols4]=undef; }
  foreach $key (keys %H) {
    my ($rows1, $rows2) = @{$H{$key}};
    my $nr1 = scalar @$rows1;
    my $nr2 = scalar @$rows2;
    next if ($nr1 == 0 && ($type == 0 || $type == 1));
    next if ($nr2 == 0 && ($type == 0 || $type == 2));
    if ($nr2 == 0 && ($type == 1 || $type == 3)) {
      for ($i = 0; $i < $nr1; $i++) {
        push @ones, [$self->row($rows1->[$i]), @null2];
      }
      next;
    }
    if ($nr1 == 0 && ($type == 2 || $type == 3)) {
      for ($j = 0; $j < $nr2; $j++) {
        my @row2 = $tbl->row($rows2->[$j]);
        for ($k = 0; $k< scalar @$cols1; $k++) {
          $null3[$cols1->[$k]] = $row2[$cols2->[$k]];
        }
        if ($#cols4>=0) {
          push @ones, [@null3, @row2[@cols4]];
        } else {
          push @ones, [@null3];
        } 
      }
      next;
    }
    for ($i = 0; $i < $nr1; $i++) {
      for ($j = 0; $j < $nr2; $j++) {
        my @row2 = $tbl->row($rows2->[$j]);
        push @ones, [$self->row($rows1->[$i]), @row2[@cols4]];
      }
    }
  }
  my $header = [@{$self->{header}}, @header2];
  return new Data::Table(\@ones, $header, 0);
}

sub group {
  my ($self, $colsToGroupBy, $colsToCalculate, $funsToApply, $newColNames) = @_;
  confess "colsToGroupBy has to be specified!" unless defined($colsToGroupBy) && ref($colsToGroupBy) eq "ARRAY";
  my @X = ();
  foreach my $x (@$colsToGroupBy) {
    my $x_idx = $self->checkOldCol($x);
    confess "Unknown column ". $x unless defined($x_idx);
    push @X, $x_idx;
  }
  my @Y = ();
  my %Y= ();
  if (defined($colsToCalculate)) {
    foreach my $y (@$colsToCalculate) {
      my $y_idx = $self->checkOldCol($y);
      confess "Unknown column ". $y unless defined($y_idx);
      push @Y, $y_idx;
      $Y{$y_idx} = 1;
    }
  }
  if (scalar @Y) {
    confess "The size of colsToCalculate, funcsToApply and newColNames should be the same!\n"
      unless (scalar @Y == scalar @$funsToApply && scalar @Y == scalar @$newColNames);
  }

  my @header = ();
  my @X_name = ();
  my $cnt = 0;
  my $i;
  for ($i=0; $i<$self->nofCol; $i++) {
    next if defined($Y{$i});
    push @X_name, $i;
    push @header, $self->{header}->[$i];
    $cnt += 1;
  }
  if (defined($newColNames)) {
    foreach my $y (@$newColNames) {
      push @header, $y;
      $cnt += 1;
    }
  }

  my @ones = ();
  my %X = ();
  my %val = ();
  my %rowIdx = ();
  my $idx = 0;
  for ($i=0; $i<$self->nofRow; $i++) {
    my @row = ();
    my $myRow = $self->rowRef($i);
    my @val = ();
    foreach my $x (@X) {
      push @val, defined($myRow->[$x])?$myRow->[$x]:"";
    }
    my $myKey = CORE::join("\t", @val);
    if (scalar @Y) {
      my %Y = ();
      foreach my $y (@Y) {
        next if defined($Y{$y});
        $Y{$y} = 1;
        if (defined($val{$y}->{$myKey})) {
          push @{$val{$y}->{$myKey}}, $myRow->[$y];
        } else {
          $val{$y}->{$myKey} = [$myRow->[$y]];
        }
      }
    }
    next if defined($X{$myKey});
    $X{$myKey} = 1;
    foreach my $j (@X_name) {
      push @row, $myRow->[$j];
    }
    $row[$cnt-1] = undef if (scalar @row < $cnt);
    push @ones, \@row;
    $rowIdx{$myKey} = $idx++;
  }

  if (scalar @Y) {
    $cnt -= scalar @Y;
    for($i=0; $i<scalar @Y; $i++) {
      foreach my $s (keys %X) {
        if (ref($funsToApply->[$i]) eq "CODE") {
          $ones[$rowIdx{$s}]->[$cnt+$i] = $funsToApply->[$i]->(@{$val{$Y[$i]}->{$s}});
        } else {
          confess "The ${i}th element in the function array is not a valid reference!\n";
        }
      }
    }
  }

  return new Data::Table(\@ones, \@header, 0);
}

sub pivot {
  my ($self, $colToSplit, $colToSplitIsNumeric, $colToFill, $colsToGroupBy, $keepRestCols) = @_;
  $keepRestCols = 0 unless defined($keepRestCols);
  $colToSplitIsNumeric = 1 unless defined($colToSplitIsNumeric);
  my $y = $self->checkOldCol($colToSplit);
  my $y_name = defined($y)?$self->{header}->[$y]:undef;
  confess "Unknown column ". $colToSplit if (!defined($y) && defined($colToSplit));
  my $z = $self->checkOldCol($colToFill);
  my $z_name = defined($z)?$self->{header}->[$z]:undef;
  confess "Unknown column ". $colToFill if (!defined($z) && defined($colToFill));
  confess "Cannot take colToFill, if colToSplit is 'undef'" if (defined($z) && !defined($y));
  my @X = ();
  if (defined($colsToGroupBy)) {
    foreach my $x (@$colsToGroupBy) {
      my $x_idx = $self->checkOldCol($x);
      confess "Unknown column ". $x unless defined($x_idx);
      push @X, $self->{header}->[$x_idx];
    }
  }
  my ($val, @Y, %Y);

  if (defined($colToSplit)) {
    @Y = $self->col($y);
    %Y = ();
    foreach $val (@Y) {
      $val = "NULL" unless defined($val);
      $Y{$val} = 1;
    }
  }

  if ($colToSplitIsNumeric) {
    @Y = sort { $a <=> $b } (keys %Y);
  } else {
    @Y = sort { $a cmp $b } (keys %Y);
  }

  my @header = ();
  my $i;
  my @X_name = ();

  if (!$keepRestCols) {
    foreach my $x (@X) {
      push @X_name, $x;
    }
  } else {
    for ($i=0; $i<$self->nofCol; $i++) {
      next if ((defined($y) && $i==$y) || (defined($z) && $i==$z));
      push @X_name, $self->{header}->[$i];
    }
  }
  my $cnt = 0;
  for ($i=0; $i < @X_name; $i++) {
    my $s = $X_name[$i];
    while (defined($Y{$s})) {
      $s = "_".$s;
    }
    push @header, $s;
    $Y{$s} = $cnt++;
  }

  if (defined($y)) {
    foreach $val (@Y) {
      push @header, ($colToSplitIsNumeric?"$y_name=":"") . $val;
      $Y{$val} = $cnt++;
    }
  }

  my @ones = ();
  my %X = ();
  my $rowIdx = 0;
  for ($i=0; $i<$self->nofRow; $i++) {
    my @row = ();
    my $myRow = $self->rowHashRef($i);
    my $myKey;
    if (scalar @X) {
      my @val = ();
      foreach my $x (@X) {
        push @val, defined($myRow->{$x})?$myRow->{$x}:"";
      }
      $myKey = CORE::join("\t", @val);
    }
    unless (defined($X{$myKey})) {
      foreach my $s (@X_name) {
        push @row, $myRow->{$s};
      }
      $row[$cnt-1] = undef if (scalar @row < $cnt);
    }
    if (defined($y)) {
      my $val = $myRow->{$y_name};
      $val = "NULL" unless defined($val);
      if (!defined($X{$myKey})) {
        $row[$Y{$val}] = defined($z)?$myRow->{$z_name}:1;
      } else {
        $ones[$X{$myKey}][$Y{$val}] = defined($z)?$myRow->{$z_name}:1;
      }
    }
    unless (defined($X{$myKey})) {
      push @ones, \@row;
      $X{$myKey} = $rowIdx++;
    }
  }
  return new Data::Table(\@ones, \@header, 0);
}

sub fromFileGuessOS {
  my ($name) = @_;
  my $SRC;
  my @OS=("\n", "\r\n", "\r");
  # operatoring system: 0 for UNIX (\n as linebreak), 1 for Windows
  # (\r\n as linebreak), 2 for MAC  (\r as linebreak)
  my ($len, $os)=(-1, -1);
  for (my $i=0; $i<@OS; $i++) {
    open($SRC, $name) or confess "Cannot open $name to read";
    binmode $SRC;
    local($/)=$OS[$i];
    my $s = <$SRC>;
    #print ">> $i => ". (length($s)-length($OS[$i]))."\n";
    my $myLen=length($s)-length($OS[$i]);
    if ($len<0 || ($myLen>0 && $myLen<$len)) {
      $len=length($s)-length($OS[$i]);
      $os=$i;
    }
    close($SRC);
  }
  # find the OS linebreak that gives the shortest first line
  return $os;
}

sub fromFileGetTopLines {
  my ($name, $os, $numLines) = @_;
  $os = fromFileGuessOS($name) unless defined($os);
  $numLines = 2 unless defined($numLines);
  my @OS=("\n", "\r\n", "\r"); 
  # operatoring system: 0 for UNIX (\n as linebreak), 1 for Windows
  # (\r\n as linebreak), 2 for MAC  (\r as linebreak)
  my $SRC;
  my @lines=();
  open($SRC, $name) or confess "Cannot open $name to read";
  binmode $SRC;
  local($/)=$OS[$os];
  my $n_endl = length($OS[$os]);
  my $cnt=0;
  while(<$SRC>) {
    $cnt++;
    for (1..$n_endl) { chop; }
    push @lines, $_;
    last if ($numLines>0 && $cnt>=$numLines);
  }
  close($SRC);
  return @lines;
}

sub fromFileIsHeader {
  my ($s, $delimiter) = @_;
  $delimiter=$Data::Table::DEFAULTS{'CSV_DELIMITER'} unless defined($delimiter);
  return 0 if (!defined($s) || $s eq "" || $s=~ /$delimiter$/);
  my $fields=parseCSV($s, 0, {delimiter=>$delimiter});
  foreach my $name (@$fields) {
    return 0 unless $name;
    next if $name=~/[^0-9.eE\-+]/;
    return 0 if $name=~/^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/;
  }
  return 1;
}

sub fromFileGuessDelimiter {
  my $s_line= shift;
  my @DELIMITER=(",","\t",":");
  my $numCol=-1; my $i=-1;
  return $Data::Table::DEFAULTS{CSV_DELIMITER} unless @$s_line;
  for (my $d=0; $d<@DELIMITER; $d++) {
    my $colFound=-1;
    foreach my $line (@$s_line) {
      unless (defined($line)) {
        return $Data::Table::DEFAULTS{CSV_DELIMITER};
      } else {
        my $header = parseCSV($line, 0, {delimiter=>$DELIMITER[$d]});
        if ($colFound<0) {
          $colFound = scalar @$header;
        } elsif ($colFound != scalar @$header) {
          $colFound = -1;
          last;
        }
      }
    }
    next if $colFound<0;
    if ($colFound>$numCol) {
      $numCol=$colFound; $i=$d;
    }
  }
  return ($i<0)?$Data::Table::DEFAULTS{CSV_DELIMITER}:$DELIMITER[$i];
}

sub fromFile {
  my ($name, $arg_ref) = @_;
  my $linesChecked = 2;
  $linesChecked= $arg_ref->{'OS'} if (defined($arg_ref) && defined($arg_ref->{'OS'}));
  if (defined($arg_ref)) {
    $linesChecked = $arg_ref->{'linesChecked'} if defined($arg_ref->{'linesChecked'});
  }
  my $os = fromFileGuessOS($name);
  my @S = fromFileGetTopLines($name, $os, $linesChecked);
  return undef unless scalar @S;
  my $delimiter = fromFileGuessDelimiter(\@S);
  my $hasHeader = fromFileIsHeader($S[0], $delimiter);
  my $t = undef;
  #print ">>>". join("\n", @S)."\n";
  #print "OS=$os, hasHeader=$hasHeader, delimiter=$delimiter\n";
  if ($delimiter eq "\t") {
    $t=fromTSV($name, $hasHeader, undef, {OS=>$os});
  } else {
    $t=fromCSV($name, $hasHeader, undef, {OS=>$os, delimiter=>$delimiter});
  }
  return $t;
}

## interface to GD::Graph
# use GD::Graph::points;
# $graph = GD::Graph::points->new(400, 300);
# $graph->plot([$t->colRef(1), $t->colRef(2)]);
 
1;

__END__


=head1 NAME

Data::Table - Data type related to database tables, spreadsheets, CSV/TSV files, HTML table displays, etc.

=head1 SYNOPSIS

  # some cool ways to use Table.pm
  use Data::Table;
  
  $header = ["name", "age"];
  $data = [
    ["John", 20],
    ["Kate", 18],
    ["Mike", 23]
  ];
  $t = new Data::Table($data, $header, 0);	# Construct a table object with
					# $data, $header, $type=0 (consider 
					# $data as the rows of the table).
  print $t->csv;                        # Print out the table as a csv file.

  $t = Data::Table::fromCSV("aaa.csv");       # Read a csv file into a table object
  ### Since version 1.51, a new method fromFile can automatically guess the correct file format
  # either CSV or TSV file, file with or without a column header line
  # e.g.
  #   $t = Data::Table::fromFile("aaa.csv");
  # is equivalent.
  print $t->html;                       # Display a 'portrait' HTML TABLE on web. 

  use DBI;
  $dbh= DBI->connect("DBI:mysql:test", "test", "") or die $DBI::errstr;
  my $minAge = 10;
  $t = Data::Table::fromSQL($dbh, "select * from mytable where age >= ?", [$minAge]);
					# Construct a table form an SQL 
					# database query.

  $t->sort("age", 0, 0);                # Sort by col 'age',numerical,ascending
  print $t->html2;                      # Print out a 'landscape' HTML Table.  

  $row = $t->delRow(2);			# Delete the third row (index=2).
  $t->addRow($row, 4);			# Add the deleted row back as fifth row. 
  @rows = $t->delRows([0..2]);		# Delete three rows (row 0 to 2).
  $col = $t->delCol("age");		# Delete column 'age'.
  $t->addCol($col, "age",2);		# Add column 'age' as the third column
  @cols = $t->delCols(["name","phone","ssn"]); 
					# Delete 3 columns at the same time. 

  $name =  $t->elm(2,"name");	        # Element access
  $t2=$t->subTable([1, 3..4],['age', 'name']);	
					# Extract a sub-table 

  $t->rename("Entry", "New Entry");	# Rename column 'Entry' by 'New Entry'
  $t->replace("Entry", [1..$t->nofRow()], "New Entry");	
					# Replace column 'Entry' by an array of
					# numbers and rename it as 'New Entry'
  $t->swap("age","ssn");		# Swap the positions of column 'age' 
					# with column 'ssn' in the table.

  $t->colMap('name', sub {return uc});  # Map a function to a column 
  $t->sort('age',0,0,'name',1,0);	# Sort table first by the numerical 
					# column 'age' and then by the 
					# string column 'name' in ascending
					# order
  $t2=$t->match_pattern('$_->[0] =~ /^L/ && $_->[3]<0.2'); 
					# Select the rows that matched the 
					# pattern specified 
  $t2=$t->match_string('John');		# Select the rows that matches 'John'   
					# in any column

  $t2=$t->clone();			# Make a copy of the table.
  $t->rowMerge($t2);			# Merge two tables
  $t->colMerge($t2);

  $t = new Data::Table(                 # create an employ salary table
    [
      ['Tom', 'male', 'IT', 65000],
      ['John', 'male', 'IT', 75000],
      ['Tom', 'male', 'IT', 65000],
      ['John', 'male', 'IT', 75000],
      ['Peter', 'male', 'HR', 85000],
      ['Mary', 'female', 'HR', 80000],
      ['Nancy', 'female', 'IT', 55000],
      ['Jack', 'male', 'IT', 88000],
      ['Susan', 'female', 'HR', 92000]
    ],
    ['Name', 'Sex', 'Department', 'Salary'], 0);
  
  sub average {  # this is an subroutine calculate mathematical average, ignore NULL
    my @data = @_;
    my ($sum, $n) = (0, 0);
    foreach $x (@data) {
      next unless $x;
      $sum += $x; $n++;
    }
    return ($n>0)?$sum/$n:undef;
  }
  
  $t2 = $t->group(["Department","Sex"],["Name", "Salary"], [sub {scalar @_}, \&average], ["Nof Employee", "Average Salary"]);
  # For each (Department,Sex) pair, calculate the number of employees and average salary
  $t2 = $t2->pivot("Sex", 0, "Average Salary", ["Department"]);
  # Show average salary information in a Department by Sex spreadsheet

=head1 ABSTRACT

This perl package uses perl5 objects to make it easy for
manipulating spreadsheet data among disk files, database, and Web
publishing.

A table object contains a header and a two-dimensional array of scalars.
Four class methods Data::fromFile, Data::Table::fromCSV, Data::Table::fromTSV, and Data::Table::fromSQL allow users
to create a table object from a CSV/TSV file or a database SQL selection in a snap.

Table methods provide basic access, add, delete row(s) or column(s) operations, as well as more advanced sub-table extraction, table sorting,
record matching via keywords or patterns, table merging, and web publishing.   
Data::Table class also provides a straightforward interface to other
popular Perl modules such as DBI and GD::Graph.

The current version of Table.pm is available at http://easydatabase.googlepages.com

We use Data::Table instead of Table, because Table.pm has already been used inside PerlQt module in CPAN.

=head1 INTRODUCTION

=over 4

A table object has three data members:

=item 1. $data:

a reference to an array of array-references.
It's basically a reference to a two-dimensional array.

=item 2. $header:

a reference to a string array. The array contains all the column names.

=item 3. $type = 1 or 0.

1 means that @$data is an array of table columns (fields) (column-based);
0 means that @$data is an array of table rows (records) (row-based);

=back

Row-based/Column-based are two internal implementations for a table object.
E.g., if a spreadsheet consists of two columns lastname and age.
In a row-based table, $data = [ ['Smith', 29], ['Dole', 32] ].
In a column-based table, $data = [ ['Smith', 'Dole'], [29, 32] ].

Two implementations have their pros and cons for different operations.
Row-based implementation is better for sorting and pattern matching,
while column-based one is better for adding/deleting/swapping columns.

Users only need to specify the implementation type of the table upon its
creation via Data::Table::new, and can forget about it afterwards.
Implementation type of a table should be considered volatile, because
methods switch table objects from one type into another internally.
Be advised that row/column/element references gained via table::rowRef,
table::rowRefs, table::colRef, table::colRefs, or table::elmRef may
become stale after other method calls afterwards.

For those who want to inherit from the Data::Table class, internal method
table::rotate is used to switch from one implementation type into another.
There is an additional internal assistant data structure called
colHash in our current implementation. This hash
table stores all column names and their corresponding column index number as
key-value pairs for fast conversion. This gives users an option to use
column name wherever a column ID is expected, so that user don't have to use
table::colIndex all the time. E.g., you may say
$t->rename('oldColName', 'newColName')
instead of $t->rename($t->colIndex('oldColName'), 'newColIdx').

=head1 DESCRIPTION

=head2 Field Summary

=over 4

=item data refto_arrayof_refto_array

contains a two-dimensional spreadsheet data.

=item header refto_array

contains all column names.

=item type 0/1

0 is row-based, 1 is column-based, describe the orientation of @$data.

=back

=head2 Package Variables

=over 4

=item $Data::Table::VERSION

=item @Data::Table::OK

see table::match_string and table::match_pattern

=item %Data::Table::DEFAULTS

Store default settings, currently it contains CSV_DELIMITER (set to ','), CSV_QUALIFER (set to '"'), and OS (set to 0).
see table::fromCSV, table::csv, table::fromTSV, table::tsv for details.

=back

=head2 Class Methods

Syntax: return_type method_name ( [ parameter [ = default_value ]] [, parameter [ = default_value ]] )

If method_name starts with table::, this is an instance method, it can be used as $t->method( parameters ), where $t is a table reference.

If method_name starts with Data::Table::, this is a class method, it should be called as
  Data::Table::method, e.g., $t = Data::Table::fromCSV("filename.csv").

Conventions for local variables:

  colID: either a numerical column index or a column name;
  rowIdx: numerical row index;
  rowIDsRef: reference to an array of column IDs;
  rowIdcsRef: reference to an array of row indices;
  rowRef, colRef: reference to an array of scalars;
  data: ref_to_array_of_ref_to_array of data values;
  header: ref to array of column headers;
  table: a table object, a blessed reference.

=head2 Table Creation

=over 4

=item table Data::Table::new ( $data = [], $header = [], $type = 0, $enforceCheck = 1)

create a new table.
It returns a table object upon success, undef otherwise.
$data: points to the spreadsheet data.
$header: points to an array of column names. A column name must have at least one non-digit character.
$type: 0 or 1 for row-based/column-based spreadsheet.
$enforceCheck: 1/0 to turn on/off initial checking on the size of each row/column to make sure the data arguement indeed points to a valid structure.

=item table table::subTable ($rowIdcsRef, $colIDsRef)

create a new table, which is a subset of the original.
It returns a table object.
$rowIdcsRef: points to an array of row indices.
$colIDsRef: points to an array of column IDs.
The function make a copy of selected elements from the original table. 
Undefined $rowIdcsRef or $colIDsRef is interpreted as all rows or all columns.

=item table table::clone

make a clone of the original.
It return a table object, equivalent to table::subTable(undef,undef).

=item table Data::Table::fromCSV ($name_or_handler, $includeHeader = 1, $header = ["col1", ... ], {OS=>$Data::Table::DEFAULTS{'OS'}, delimiter=>$Data::Table::DEFAULTS{'CSV_DELIMITER'}, qualifier=>$Data::Table::DEFAULTS{'CSV_QUALIFIER'}, skip_lines=>0, skip_pattern=>undef})

create a table from a CSV file.
return a table object.
$name_or_handler: the CSV file name or an already opened file handler. If a handler is used, it's not closed upon return.
$includeHeader: 0 or 1 to ignore/interpret the first line in the file as column names,
If it is set to 0, the array in $header is used. If $header is not supplied, the default column names are "col1", "col2", ...
optional named argument OS specifies under which operating system the CSV file was generated. 0 for UNIX, 1 for PC and 2 for MAC. If not specified, $Data::Table::DEFAULTS{'OS'} is used, which defaults to UNIX. Basically linebreak is defined as "\n", "\r\n" and "\r" for three systems, respectively.

optional name argument delimiter and qualifier let user replace comma and double-quote by other meaningful single characters. <b>Exception</b>: if the delimiter or the qualifier is a special symbol in regular expression, you must escape it by '\'. For example, in order to use pipe symbol as the delimiter, you must specify the delimiter as '\|'.

optional name argument skip_lines let you specify how many lines in the csv file should be skipped, before the data are interpretted.

optional name argument skip_pattern let you specify a regular expression. Lines that match the regular expression will be skipped.

The following example reads a DOS format CSV file and writes a MAC format:

  $t = Data::Table:fromCSV('A_DOS_CSV_FILE.csv', 1, undef, {OS=>1});
  $t->csv(1, {OS=>2, file=>'A_MAC_CSV_FILE.csv'});
  open(SRC, 'A_DOS_CSV_FILE.csv') or die "Cannot open A_DOS_CSV_FILE.csv to read!";
  $t = Data::Table::fromCSV(\*SRC, 1);
  close(SRC);

The following example reads a non-standard CSV file with : as the delimiter, ' as the qaulifier

  my $s="col_A:col_B:col_C\n1:2, 3 or 5:3.5\none:'one:two':'double\", single'''";
  open my $fh, "<", \$s or die "Cannot open in-memory file\n";
  my $t_fh=Data::Table::fromCSV($fh, 1, undef, {delimiter=>':', qualifier=>"'"});
  close($fh);
  print $t_fh->csv;
  # convert to the standard CSV (comma as the delimiter, double quote as the qualifier)
  # col_A,col_B,col_C
  # 1,"2, 3 or 5",3.5
  # one,one:two,"double"", single'"
  print $t->csv(1, {delimiter=>':', qualifier=>"'"}); # prints the csv file use the original definition

The following example reads bbb.csv file (included in the package) by skipping the first line (skip_lines=>1), then treats any line that starts with '#' (or space comma) as comments (skip_pattern=>'^\s*#'), use ':' as the delimiter.

  $t = Data::Table::fromCSV("bbb.csv", 1, undef, {skip_lines=>1, delimiter=>':', skip_pattern=>'^\s*#'});

=item table table::fromCSVi ($name, $includeHeader = 1, $header = ["col1", ... ])

Same as Data::Table::fromCSV. However, this is an instant method (that's what 'i' stands for), which can be inherited.

=item table Data::Table::fromTSV ($name, $includeHeader = 1, $header = ["col1", ... ], {OS=>$Data::Table::DEFAULTS{'OS'}, skip_lines=>0, skip_pattern=>undef})

create a table from a TSV file.
return a table object.
$name: the TSV file name or an already opened file handler. If a handler is used, it's not closed upon return..
$includeHeader: 0 or 1 to ignore/interpret the first line in the file as column names,
If it is set to 0, the array in $header is used. If $header is not supplied, the default column names are "col1", "col2", ...
optional named argument OS specifies under which operating system the TSV file was generated. 0 for UNIX, 1 for P
C and 2 for MAC. If not specified, $Data::Table::DEFAULTS{'OS'} is used, which defaults to UNIX. Basically linebreak is defined as "\n", "\r\n" and "\r" for three systems, respectively.  <b>Exception</b>: if the delimiter or the qualifier is a special symbol in regular expression, you must escape it by '\'. For example, in order to use pipe symbol as the delimiter, you must specify the delimiter as '\|'.

optional name argument skip_lines let you specify how many lines in the csv file should be skipped, before the data are interpretted.

optional name argument skip_pattern let you specify a regular expression. Lines that match the regular expression will be skipped.

See similar examples under Data::Table::fromCSV;

Note: read "TSV FORMAT" section for details.

=item table table::fromTSVi ($name, $includeHeader = 1, $header = ["col1", ... ])

Same as Data::Table::fromTSV. However, this is an instant method (that's what 'i' stands for), which can be inherited.

=item table Data::Table::fromFile ($file_name, {linesChecked=>2})

create a table from a text file.
return a table object.
$file_name: the file name (cannot take a file handler).
linesChecked: the first number of lines used for guessing the input format. The delimiter will have to produce the same number of columns for these lines. By default only check the first 2 lines, 0 means all lines in the file.

fromFile is added after version 1.51. It relies on the following new methods to automatically figure out the correct file format in order to call fromCSV or fromTSV internally:

  fromFileGuessOS($file_name)
    returns integer, 0 for UNIX, 1 for PC, 2 for MAC
  fromFileGetTopLines($file_name, $os, $lineNumber) # $os defaults to fromFileGuessOS($file_name), if not specified
    returns an array of strings, each string represents each row with linebreak removed.
  fromFileGuessDelimiter($lineArrayRef)       # guess delimiter from ",", "\t", ":";
    returns the guessed delimiter string.
  fromFileIsHeader($line_concent, $delimiter) # $delimiter defaults to $Data::Table::DEFAULTS{'CSV_DELIMITER'}
    returns 1 or 0.

It first ask fromFileGuessOS to figure out which OS (UNIX, PC or MAC) generated the input file. The fetch the first linesChecked lines using fromFileGetTopLines. It then guesses the best delimiter using fromFileGuessDelimiter, then it checks if the first line looks like a column header row using fromFileIsHeader. Since fromFileGuessOS and fromFileGetTopLines needs to open/close the input file, these methods can only take file name, not file handler.

fromFileGuessOS finds the linebreak that gives shortest first line (in the priority of UNIX, PC, MAC upon tie).
fromFileGuessDelimiter works based on the assumption that the correct delimiter will produce equal number of columns for the given rows. If multiple matches, it chooses the delimiter that gives maximum number of columns. If none matches, it returns the default delimiter.
fromFileIsHeader works based on the assumption that no column header can be empty or pure numeric value.

=item table Data::Table::fromSQL ($dbh, $sql, $vars)

create a table from the result of an SQL selection query.
It returns a table object upon success or undef otherwise.
$dbh: a valid database handler. 
Typically $dbh is obtained from DBI->connect, see "Interface to Database" or DBI.pm.
$sql: an SQL query string.
$vars: optional reference to an array of variable values, 
required if $sql contains '?'s which need to be replaced 
by the corresponding variable values upon execution, see DBI.pm for details.
Hint: in MySQL, Data::Table::fromSQL($dbh, 'show tables from test') will also create a valid table object.

=item table Data::Table::fromSQLi ($dbh, $sql, $vars)

Same as Data::Table::fromSQL. However, this is an instant method (that's what 'i' stands for), whic
h can be inherited.

=back

=head2 Table Access and Properties

=over 4

=item int table::colIndex ($colID)

translate a column name into its numerical position, the first column has index 0 as in as any perl array.
return -1 for invalid column names.

=item int table::nofCol

return number of columns.

=item int table::nofRow

return number of rows.

=item scalar table::elm ($rowIdx, $colID)

return the value of a table element at [$rowIdx, $colID],
undef if $rowIdx or $colID is invalid. 

=item refto_scalar table::elmRef ($rowIdx, $colID)

return the reference to a table element at [$rowIdx, $colID], to allow possible modification.
It returns undef for invalid $rowIdx or $colID. 

=item array table::header ($header)

Without argument, it returns an array of column names.
Otherwise, use the new header.

=item int table::type

return the implementation type of the table (row-based/column-based) at the time,
be aware that the type of a table should be considered as volatile during method calls.

=back

=head2 Table Formatting

=over 4

=item string table::csv ($header, {OS=>$Data::Table::DEFAULTS{'OS'}, file=>undef, delimiter=>$Data::Table::DEFAULTS{'CSV_DELIMITER'}, qualifier=>$Data::Table::DEFAULTS{'CSV_QAULIFIER'}})

return a string corresponding to the CSV representation of the table.
$header controls whether to print the header line, 1 for yes, 0 for no.
optional named argument OS specifies for which operating system the CSV file is generated. 0 for UNIX, 1 for P
C and 2 for MAC. If not specified, $Data::Table::DEFAULTS{'OS'} is used. Basically linebreak is defined as "\n", "\r\n" and "\r" for three systems, respectively.
if 'file' is given, the csv content will be written into it, besides returning the string.
One may specify custom delimiter and qualifier if the other than default are desired.

=item string table::tsv

return a string corresponding to the TSV representation of the table.
$header controls whether to print the header line, 1 for yes, 0 for no.
optional named argument OS specifies for which operating system the TSV file is generated. 0 for UNIX, 1 for P
C and 2 for MAC. If not specified, $Data::Table::DEFAULTS{'OS'} is used. Basically linebreak is defined as "\n", "\r\n" and "\r" for three systems, respectively.
if 'file' is given, the tsv content will be written into it, besides returning the string.

Note: read "TSV FORMAT" section for details.

=item string table::html ($colors = ["#D4D4BF","#ECECE4","#CCCC99"], 
			  $tag_tbl = {border => '1'},
                          $tag_tr  = {align => 'left'},
                          $tag_th  = {align => 'center'},
                          $tag_td  = {col3 => 'align="right" valign="bottom"', 4 => 'align="left"'},
                          $l_portrait = 1
                        )

return a string corresponding to a 'Portrait/Landscape'-style html-tagged table.
$colors: a reference to an array of three color strings, used for backgrounds for table header, odd-row records, and even-row records, respectively. 
A default color array ("#D4D4BF","#ECECE4","#CCCC99")
will be used if $colors isn't defined. 

$tag_tbl: a reference to a hash that specifies any legal attributes such as name, border,
id, class, etc. for the TABLE tag.

$tag_tr: a reference to a hash that specifies any legal attributes for the TR tag.

$tag_th: a reference to a hash that specifies any legal attributes for the TH tag.

$tag_td: a reference to a hash that specifies any legal attributes for the TD tag.

Notice $tag_tr and $tag_th controls all the rows and columns of the whole table. The keys of the hash are the attribute names in these cases. However, $tag_td is column specific, i.e., you should specify TD attributes for every column separately.
The key of %$tag_td are either column names or column indices, the value is the full string to be inserted into the TD tag. E.g., $tag_td  = {col3 => 'align=right valign=bottom} only change the TD tag in "col3" to be &lt;TD align=right valign=bottom&gt;.

$portrait controls the layout of the table. The default is 1, i.e., the table is shown in the
"Portrait" style, like in Excel. 0 means "Landscape".

Attention: You will have to escape HTML-Entities yourself (for example '<' as '&lt;'), if you have characters in you table which need to be escaped. You can do this for example with the escapeHTML-function from CGI.pm (or the HTML::Entities module).

  use CGI qw(escapeHTML);
  [...]
  $t->colMap($columnname, sub{escapeHTML($_)}); # for every column, where HTML-Entities occur.

=item string table::html2 ($colors = ["#D4D4BF","#ECECE4","#CCCC99"],
		 	   $specs = {'name' => '', 'border' => '1', ...})

This method is deprecated. It's here for compatibility. It now simple call html method with $portrait = 0, see previous description.

return a string corresponding to a "Landscape" html-tagged table.
This is useful to present a table with many columns, but very few entries.
Check the above table::html for parameter descriptions.

=back

=head2 Table Operations

=over 4

=item int table::setElm ($rowIdx, $colID, $val)

modify the value of a table element at [$rowIdx, $colID] to a new value $val.
It returns 1 upon success, undef otherwise. 


=item int table::addRow ( $rowRef, $rowIdx = table::nofRow)

add a new row ($rowRef points to the actual list of scalars), the new row will be referred as $rowIdx as the result. E.g., addRow($aRow, 0) will put the new row as the very first row.
By default, it appends a row to the end.
It returns 1 upon success, undef otherwise.

=item refto_array table::delRow ( $rowIdx )

delete a row at $rowIdx. It will the reference to the deleted row.

=item refto_array table::delRows ( $rowIdcsRef )

delete rows in @$rowIdcsRef. It will return an array of deleted rows
upon success.

=item int table::addCol ($colRef, $colName, $colIdx = numCol)

add a new column ($colRef points to the actual data), the new column will be referred as $colName or $colIdx as the result. E.g., addCol($aCol, 'newCol', 0) will put the new column as the very first column.
By default, append a row to the end.
It will return 1 upon success or undef otherwise.

=item refto_array table::delCol ($colID)

delete a column at $colID
return the reference to the deleted column.

=item arrayof_refto_array table::delCols ($colIDsRef)

delete a list of columns, pointed by $colIDsRef. It will
return an array of deleted columns upon success.

=item refto_array table::rowRef ($rowIdx)

return a reference to the row at $rowIdx
upon success or undef otherwise.

=item refto_arrayof_refto_array table::rowRefs ($rowIdcsRef)

return a reference to array of row references upon success, undef otherwise.

=item array table::row ($rowIdx)

return a copy of the row at $rowIdx 
upon success or undef otherwise.

=item refto_hash table::rowHashRef ($rowIdx)

return a reference to a hash, which contains a copy of the row at $rowIdx,
upon success or undef otherwise. The keys in the hash are column names, and
the values are corresponding elements in that row. The hash is a copy, therefore modifying the hash values doesn't change the original table.

=item refto_array table::colRef ($colID)

return a reference to the column at $colID
upon success.

=item refto_arrayof_refto_array table::colRefs ($colIDsRef)

return a reference to array of column references upon success.

=item array table::col ($colID)

return a copy to the column at $colID
upon success or undef otherwise.

=item int table::rename ($colID, $newName)

rename the column at $colID to a $newName 
(the newName must be valid, 
and should not be identical to any other existing column names).
It returns 1 upon success
or undef otherwise.

=item refto_array table::replace ($oldColID, $newColRef, $newName)

replace the column at $oldColID by the array pointed by $newColRef, and renamed it to $newName. $newName is optional if you don't want to rename the column.
It returns 1 upon success or undef otherwise.

=item int table::swap ($colID1, $colID2)

swap two columns referred by $colID1 and $colID2.
It returns 1 upon success or undef otherwise.

=item int table::colMap ($colID, $fun)

foreach element in column $colID, map a function $fun to it.
It returns 1 upon success or undef otherwise.
This is a handy way to format a column. E.g. if a column named URL contains URL strings, colMap("URL", sub {"<a href='$_'>$_</a>"}) before html() will change each URL into a clickable hyper link while displayed in a web browser.

=item int table::colsMap ($fun)

foreach row in the table, map a function $fun to it.
It can do whatever colMap can do and more.
It returns 1 upon success or undef otherwise.
colMap function only give $fun access to the particular element per row, while colsMap give $fun full access to all elements per row. E.g. if two columns named duration and unit (["2", "hrs"], ["30", "sec"]). colsMap(sub {$_->[0] .= " (".$_->[1].")"; } will change each row into (["2 hrs", "hrs"], ["30 sec", "sec"]).
As show, in the $func, a column element should be referred as $_->[$colIndex].

=item int table::sort($colID1, $type1, $order1, $colID2, $type2, $order2, ... )

sort a table in place.
First sort by column $colID1 in $order1 as $type1, then sort by $colID2 in $order2 as $type2, ...
$type is 0 for numerical and 1 for others;
$order is 0 for ascending and 1 for descending;
Sorting is done in the priority of colID1, colID2, ...
It returns 1 upon success or undef otherwise. 
Notice the table is rearranged as a result! This is different from perl's list sort, which returns a sorted copy while leave the original list untouched, 
the authors feel inplace sorting is more natural.

table::sort can take a user supplied operator, this is useful when neither numerical nor alphabetic order is correct.

  $Well=["A_1", "A_2", "A_11", "A_12", "B_1", "B_2", "B_11", "B_12"];
  $t = new Data::Table([$Well], ["PlateWell"], 1);
  $t->sort("PlateWell", 1, 0);
  print join(" ", $t->col("PlateWell"));
  # prints: A_1 A_11 A_12 A_2 B_1 B_11 B_12 B_2
  # in string sorting, "A_11" and "A_12" appears before "A_2";
  my $my_sort_func = sub {
    my @a = split /_/, $_[0];
    my @b = split /_/, $_[1];
    my $res = ($a[0] cmp $b[0]) || (int($a[1]) <=> int($b[1]));
  };
  $t->sort("PlateWell", $my_sort_func, 0);
  print join(" ", $t->col("PlateWell"));
  # prints the correct order: A_1 A_2 A_11 A_12 B_1 B_2 B_11 B_12

=item table table::match_pattern ($pattern, $countOnly)

return a new table consisting those rows evaluated to be true by $pattern 
upon success or undef otherwise. If $countOnly is set to 1, it simply returns the number of rows that matches the string without making a new copy of table. $countOnly is 0 by default.

Side effect: @Data::Table::OK stores a true/false array for the original table rows. Using it, users can find out what are the rows being selected/unselected.
In the $pattern string, a column element should be referred as $_->[$colIndex]. E.g., match_pattern('$_->[0]>3 && $_->[1]=~/^L') retrieve all the rows where its first column is greater than 3 and second column starts with letter 'L'. Notice it only takes colIndex, column names are not acceptable here!

=item table table::match_string ($s, $caseIgnore, $countOnly)

return a new table consisting those rows contains string $s in any of its fields upon success, undef otherwise. if $caseIgnore evaluated to true, case will is be ignored (s/$s/i). If $countOnly is set to 1, it simply returns the number of rows that matches the string without making a new copy of table. $countOnly is 0 by default.

Side effect: @Data::Table::OK stores a true/false array for the original table rows. 
Using it, users can find out what are the rows being selected/unselected.
The $s string is actually treated as a regular expression and 
applied to each row element, therefore one can actually specify several keywords 
by saying, for instance, match_string('One|Other').

=item table table::rowMask($mask, $complement)

mask is reference to an array, where elements are evaluated to be true or false. The size of the mask must be equal to the nofRow of the table. return a new table consisting those rows where the corresponding mask element is true (or false, when complement is set to true).

E.g., $t1=$tbl->match_string('keyword'); $t2=$tbl->rowMask(\@Data::Table::OK, 1) creates two new tables. $t1 contains all rows match 'keyword', while $t2 contains all other rows.

mask is reference to an array, where elements are evaluated to be true or false. The size of the mask must be equal to the nofRow of the table. return
 a new table consisting those rows where the corresponding mask element is true (or false, when complement is set to true).

E.g., $t1=$tbl->match_string('keyword'); $t2=$tbl->rowMask(\@Data::Table::OK, 1) creates two new tables. $t1 contains all rows match 'keyword', while 
$t2 contains all other rows.

=item table table::group($colsToGroupBy, $colsToCalculate, $funsToApply, $newColNames)

Primary key columns are specified in $colsToGroupBy. All rows are grouped by primary keys first. Then for each group, an array of subroutines (in $funsToAppy) are applied to corresponding columns and yield a list of new columns (specified in $newColNames).

$colsToGroupBy, $colsToCalculate are references to array of colIDs. $funsToApply is a reference to array of subroutine references. $newColNames are a
reference to array of new column name strings. If specified, the size of arrays pointed by $colsToCalculate, $funsToApply and $newColNames should be i
dentical. A column may be used more than once in $colsToCalculate. 

E.g., an employee salary table $t contains the following columns: Name, Sex, Department, Salary. (see examples in the SYNOPSIS)

$t2 = $t->group(["Department","Sex"],["Name", "Salary"], [sub {scalar @_}, \&average], ["Nof Employee", "Average Salary"]);

Department, Sex are used together as the primary key columns, a new column "Nof Employee" is created by counting the number of employee names in each group, a new column "Average Salary" is created by averaging the Salary data falled into each group. As the result, we have the head count and average salary information for each (Department, Sex) pair. With your own functions (such as sum, product, average, standard deviation, etc), group method is very handy for accounting purpose.

=item table table::pivot($colToSplit, $colToSplitIsNumeric, $colToFill, $colsToGroupBy, $keepRestCols)

Every unique values in a column (specified by $colToSplit) become a new column. undef value become "NULL".  If the column type is numeric (specified by $colToSplitIsNumeric), the new column names are prefixed by "oldColumnName=". The new cell element is filled by the value specified by $colToFill.

When primary key columns are specified by $colsToGroupBy, all records sharing the same primary key collapse into one row, with values in $colToFill filling the corresponding new columns. If $colToFill is not specified, a cell is filled with 1 if there is a corresponding data record in the original table.

$colToSplit and $colToFill are colIDs. $colToSplitIsNumeric is 1/0. $colsToGroupBy is a reference to array of colIDs. $keepRestCols is 1/0, by default is 0. If $keepRestCols is off, only primary key columns and new columns are exported, otherwise, all the rest columns are exported as well.

E.g., applying pivot method to the resultant table of the example of the group method.

$t2->pivot("Sex", 0, "Average Salary",["Department"]);

This creates a 2x3 table, where Departments are use as row keys, Sex (female and male) become two new columns. "Average Salary" values are used to fill the new table elements. Used together with group method, pivot method is very handy for account type of analysis.

=back

=head2 Table-Table Manipulations

=over 4

=item int table::rowMerge ($tbl)

Append all the rows in the table object $tbl to the original rows.
The merging table $tbl must have the same number of columns as the original.
It returns 1 upon success, undef otherwise.
The table object $tbl should not be used afterwards, since it becomes part of
the new table.

=item int table::colMerge ($tbl)

Append all the columns in table object $tbl to the original columns. 
Table $tbl must have the same number of rows as the original.
It returns 1 upon success, undef otherwise.
Table $tbl should not be used afterwards, since it becomes part of
the new table.

=item table table::join ($tbl, $type, $cols1, $cols2)

Join two tables. The following join types are supported (defined by $type):

0: inner join
1: left outer join
2: right outer join
3: full outer join

$cols1 and $cols2 are references to array of colIDs, where rows with the same elements in all listed columns are merged. As the result table, columns listed in $cols2 are deleted, before a new table is returned.

The implementation is hash-join, the running time should be linear with respect to the sum of number of rows in the two tables (assume both tables fit in memory).

=back

=head2 Internal Methods

All internal methods are mainly implemented for used by 
other methods in the Table class. Users should avoid using them.
Nevertheless, they are listed here for developers who 
would like to understand the code and may derive a new class from Data::Table.

=over 4

=item int table::rotate

convert the internal structure of a table between row-based and column-based.
return 1 upon success, undef otherwise.

=item string csvEscape($rowRef)

Encode an array of scalars into a CSV-formatted string.

optional named arguments: delimiter and qualifier, in case user wants to use characters other than the defaults. 
The default delimiter and qualifier is taken from $Data::Table::DEFAULTS{'CSV_DELIMITER'} (defaults to ',') and $Data::Table::DEFAULTS{'CSV_QUALIFIER'} (defaults to '"'), respectively.

=item refto_array parseCSV($string)

Break a CSV encoded string to an array of scalars (check it out, we did it the cool way).

optional argument size: specify the expected number of fields after csv-split.
optional named arguments: delimiter and qualifier, in case user wants to use characters other than the defaults.
respectively. The default delimiter and qualifier is taken from $Data::Table::DEFAULTS{'CSV_DELIMITER'} (defaults to ',') and $Data::Table::DEFAULTS{'CSV_QUALIFIER'} (defaults to '"'), respectively.

=item string tsvEscape($rowRef)

Encode an array of scalars into a TSV-formatted string.

=back

=head1 TSV FORMAT

There is no standard for TSV format as far as we know. CSV format can't handle binary data very well, therefore, we choose the TSV format to overcome this limitation.

We define TSV based on MySQL convention.

  "\0", "\n", "\t", "\r", "\b", "'", "\"", and "\\" are all escaped by '\' in the TSV file.
  (Warning: MySQL treats '\f' as 'f', and it's not escaped here)
  Undefined values are represented as '\N'.

=head1 INTERFACE TO OTHER SOFTWARES

Spreadsheet is a very generic type, therefore Data::Table class provides an easy
interface between databases, web pages, CSV/TSV files, graphics packages, etc.

Here is a summary (partially repeat) of some classic usages of Data::Table.

=head2 Interface to Database and Web

  use DBI;

  $dbh= DBI->connect("DBI:mysql:test", "test", "") or die $DBI::errstr;
  my $minAge = 10;
  $t = Data::Table::fromSQL($dbh, "select * from mytable where age >= ?", [$minAge]);
  print $t->html;

=head2 Interface to CSV/TSV

  $t = fromFile("mydata.csv"); # after version 1.51
  $t = fromFile("mydata.tsv"); # after version 1.51

  $t = fromCSV("mydata.csv");
  $t->sort(1,1,0);
  print $t->csv;

  Same for TSV

=head2 Interface to Excel

  Convert between an Excel file and tables
  see Data::Table::Excel

=head2 Interface to Graphics Package

  use GD::Graph::points;

  $graph = GD::Graph::points->new(400, 300);
  $t2 = $t->match('$_->[1] > 20 && $_->[3] < 35.7');
  my $gd = $graph->plot($t->colRefs([0,2]));
  open(IMG, '>mygraph.png') or die $!;
  binmode IMG;
  print IMG $gd->png;
  close IMG;

=head1 AUTHOR

Copyright 1998-2008, Yingyao Zhou & Guangzhou Zou. All rights reserved.

It was first written by Zhou in 1998, significantly improved and maintained by Zou since 1999. The authors thank Tong Peng and Yongchuang Tao for valuable suggestions. We also thank those who kindly reported bugs, some of them are acknowledged in the "Changes" file.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Please send bug reports and comments to: easydatabase at gmail dot com. When sending
bug reports, please provide the version of Table.pm, the version of
Perl.

=head1 SEE ALSO

  Data::Table::Excel, DBI, GD::Graph.

=cut

