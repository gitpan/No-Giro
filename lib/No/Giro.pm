package No::Giro;

use strict;
use warnings;

use PostScript::Simple;

use Carp;
our $AUTOLOAD;  # it's a package global

our $VERSION = '0.02';



=head1 NAME

No::Giro - Perl Module for generating Norwegian bank slips

=head1 SYNOPSIS

  use No::Giro;
  use PostScript::Simple;
  my $p = new PostScript::Simple(papersize => "A4",
				 colour => 0,
				 eps => 0,
				 units => "mm");
  $p->newpage;
  my $giro = new No::Giro;
  $giro->kid(242345);
  $giro->belop(4534);
  $giro->tilkonto(12345678901);
  $giro->bettil(["Payme", 'Somewhere', '4932 Place']);
  my $e = $giro->eps;
  $p->importeps($e, 0,0);
  $p->output("giro.ps");


=head1 DESCRIPTION

It provides some methods to enter data into a standard F60-1 GIRO
slip. This is an A4 sheet with a standard layout and where data are
entered at the bottom and there is some space to enter any information
at the top. It returns an Encapsulated Postscript object that can be
used in a Postscript document, which again is suitable to be printed. 


=head2 Data Methods

This are the accessor methods, they serve only the purpose of setting and retrieving the values of the data fields of the object. 

These methods have Norwegian-looking names, except for that they are abbreviations and has not Norwegian characters, so I suppose you need to be Norwegian to understand them, or grab someone who is... 

=over

=item C<belop()>

The amount of money to be payed. 

=item C<betkont()>

Does nothing. 

=item C<betinf()>

Does nothing.

=item C<frist()>

Date payment is due. Currently, it should be a simple string. 

=item C<betav()>

Name and address of the person or institution making the payment. It is an array where each element represents a line. It takes 3-4 lines and does not attempt to check that it is within bounds. 

=item C<bettil()>

Name and address of the person or institution getting the payment. Like above, it is an array where each element representing a line. 

=item C<belkonto()>

Does nothing. 

=item C<kid()>

The customer identification number, or KID. You need agreements with the banking system to actually use this meaningfully. There are constraints on length of numbers and how they are to be computed. Contact your bank for details if you plan to use this. 

=item C<tilkonto()>

The account number to be credited. 


=item C<kvittering()>

Does nothing.

=back

=cut

  
my %fields = (
	      belop => undef,
	      betkont => undef,
	      betinf => undef,
	      frist => undef,
	      betav => [],
	      bettil => [],
	      belkonto => undef,
	      kid => undef,
	      tilkonto => undef,
	      kvittering => 0,      
	      );



=head2 Other Methods

=over

=item C<new()>

The constructor of this class.

=cut

 
# Snip verbatim from perltoot by Tom Christiansen.
sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self  = {
	_permitted => \%fields,
	%fields,
    };
    bless $self, $class;
    return $self;
}


# Uhm, because of my autoload method, I don't know what to do with the destructor, so I just do this....:
sub DESTROY { # Do nothing 
}


sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self)
	or croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion
    unless (exists $self->{_permitted}->{$name} ) {
	croak "Can't access `$name' field in class $type";
    }
    if (@_) {
	return $self->{$name} = shift;
    } else {
	return $self->{$name};
    }
}

=item C<eps>

This method uses whatever data that has been previously set by the date methods, and puts them in appropriate positions, and returns a L<PostScript::Simple::EPS> object. You may then use this object to import in a L<PostScript::Simple> document, save it to a file or whatever. Just remember that it has to be imported at the very bottom of the an A4 page. 

=cut


sub eps {
    my $self = shift;
    my $eps = new PostScript::Simple(
				     xsize => 206,
				     ysize => 123,
				     eps => 1,
				     units => "pt");

    
    $eps->setfont("OCRB", 5);
    
    $eps->text(1.8,    21.5, 'H');
    $eps->text(20,     21.5, $self->{kid});
    $eps->text(90,     21.5, $self->{belop});
    $eps->text(132,    21.5, $self->{tilkonto});
 
    if($self->{bettil}) {
	my $feed = 60; 
	foreach my $line (@{$self->{bettil}}) {
	    $eps->text(115, $feed, $line);
	    $feed-=5;
	}
    }

    if($self->{betav}) {
	my $feed = 60; 
	foreach my $line (@{$self->{betav}}) {
	    $eps->text(15, $feed, $line);
	    $feed-=5;
	}
    }
    
    $eps->text(170,    95, $self->{frist});
   
    return $eps->geteps();

}


1;
__END__

=back

=head1 BUGS/TODO

This is an early release, mostly thrown together to meet the needs of
the author. As is seen from the method documentation, it has methods
to set all sensible fields, but not all of them are implemented to
print anything.

The standard strongly recommends the use of the ISO OCR B font for the
fields that are to be OCRed, allthough Courier is also supported. I
have hardcoded "OCRB" as the font name right now, but this is
apparently not reliable, as it hasn't worked for me even on systems
with the font installed. Improving the font support is a priority in
future versions. I'm currently not aware of a free source of the OCRB
font.


Internally, I have noted some problems with the measuring units, but
right now it "works for me" and I have little time to grok the
problem.

The module could also do some checking that KID and account numbers
are valid, that's also a TODO.

I should probably have read the fine specifications for this stuff,
but it is not quite clear to me what applies... Pointers are
appreciated.

For other issues, please use the CPAN Request Tracker to report bugs. 


=head1 SEE ALSO

L<PostScript::Simple>, L<No::OCRData>.

=head1 AUTHOR

Kjetil Kjernsmo, E<lt>kk@kjernsmo.net<gt>. You may use English or Norwegian if you write me about this module. 

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Kjetil Kjernsmo

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
