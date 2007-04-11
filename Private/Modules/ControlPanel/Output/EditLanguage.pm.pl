###############################################################################
# SuperDesk                                                                   #
# Written by Gregory Nolle (greg@nolle.co.uk)                                 #
# Copyright 2002 by PlasmaPulse Solutions (http://www.plasmapulse.com)        #
###############################################################################
# Skins/ControlPanel/EditLanguage.pm.pl -> EditLanguage skin module           #
###############################################################################
# DON'T EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!                         #
###############################################################################
package Skin::CP::EditLanguage;

BEGIN { require "System.pm.pl";  import System  qw($SYSTEM ); }
BEGIN { require "General.pm.pl"; import General qw($GENERAL); }
require "Standard.pm.pl";

use HTML::Dialog;
use HTML::Form;
use strict;

sub new {
  my ($class) = @_;
  my $self    = {};
  return bless ($self, $class);
}

sub DESTROY { }

###############################################################################
# show subroutine
sub show {
  my $self = shift;
  my %in = (input => undef, @_);

  #----------------------------------------------------------------------#
  # Printing page...                                                     #

  my $Dialog = HTML::Dialog->new();
  my $Form = HTML::Form->new();

  my $Body = $Dialog->SmallHeader(
    titles => [
      { text => "", width => 1 },
      { text => "description", width => "100%" },
      { text => "id", width => 250, nowrap => 1 }
    ]
  );
  
  $Body .= $Dialog->LargeHeader(title => "Edit Language", colspan => 3);
  
  foreach my $skin (@{ $in{'input'}->{'SKINS'} }) {
    my @fields;
    $fields[0] = $Form->Radio(
      radios  => [
        { name => "SKIN", value => $skin->{'ID'} }
      ]
    );
    $fields[1] = $skin->{'DESCRIPTION'};
    $fields[2] = $skin->{'ID'};
    $Body .= $Dialog->Row(fields => \@fields);
  }
  
  my $value = $Form->Button(
    buttons => [
      { type => "submit", value => "Next >" },
      { type => "reset", value => "Cancel" }
    ], join => "&nbsp;"
  );
  
  $Body .= $Dialog->Row(fields => $value, colspan => 3);
  
  $Body = $Dialog->Body($Body);
  $Body = $Dialog->Form(
    body    => $Body,
    hiddens => [
      { name => "CP", value => "1" },
      { name => "action", value => "ListEditLanguage" },
      { name => "Username", value => $SD::ADMIN{'USERNAME'} },
      { name => "Password", value => $SD::ADMIN{'PASSWORD'} }
    ]
  );
  $Body = $Dialog->Page(body => $Body);
  
  return $Body;
}

###############################################################################
# list subroutine
sub list {
  my $self = shift;
  my %in = (input => undef, @_);

  #----------------------------------------------------------------------#
  # Printing page...                                                     #

  my $Dialog = HTML::Dialog->new();
  my $Form = HTML::Form->new();

  my $Body = $Dialog->SmallHeader(
    titles => [
      { text => "", width => 1 },
      { text => "language file", width => "100%" }
    ]
  );
  
  $Body .= $Dialog->LargeHeader(title => "Edit Language", colspan => 2);
  
  foreach my $file (@{ $in{'input'}->{'LANGUAGE_FILES'} }) {
    my @fields;
    $fields[0] = $Form->Radio(
      radios  => [
        { name => "LANGUAGE", value => $file }
      ]
    );
    $fields[1] = $file;
    $Body .= $Dialog->Row(fields => \@fields);
  }
  
  my $value = $Form->Button(
    buttons => [
      { type => "submit", value => "Next >" },
      { type => "reset", value => "Cancel" }
    ], join => "&nbsp;"
  );
  
  $Body .= $Dialog->Row(fields => $value, colspan => 2);
  
  $Body = $Dialog->Body($Body);
  $Body = $Dialog->Form(
    body    => $Body,
    hiddens => [
      { name => "SKIN", value => $SD::QUERY{'SKIN'} },
      { name => "CP", value => "1" },
      { name => "action", value => "ViewEditLanguage" },
      { name => "Username", value => $SD::ADMIN{'USERNAME'} },
      { name => "Password", value => $SD::ADMIN{'PASSWORD'} }
    ]
  );
  $Body = $Dialog->Page(body => $Body);
  
  return $Body;
}

###############################################################################
# view subroutine
sub view {
  my $self = shift;
  my %in = (input => undef, error => "", @_);

  #----------------------------------------------------------------------#
  # Printing page...                                                     #

  my $Dialog = HTML::Dialog->new();
  my $Form = HTML::Form->new();

  my $Body = $Dialog->SmallHeader(titles => "edit language");

  my @keys = keys(%{ $in{'input'}->{'LANGUAGE'} });
     @keys = sort { ref($in{'input'}->{'LANGUAGE'}->{$a}) cmp ref($in{'input'}->{'LANGUAGE'}->{$b}) } @keys;

  for (my $h = 0; $h <= $#keys; $h++) {
    my $key = $keys[$h];
    my $Temp;
    if (ref($in{'input'}->{'LANGUAGE'}->{$key}) eq "HASH") {
      foreach my $key2 (keys %{ $in{'input'}->{'LANGUAGE'}->{$key} }) {
        $Temp .= $Dialog->TextBox(
          name      => "FORM_".$key."-".$key2,
          value     => &Standard::HTMLize($SD::QUERY{'FORM_'.$key."-".$key2} || $in{'input'}->{'LANGUAGE'}->{$key}->{$key2}),
          subject   => $key2
        );
      }
      $Body .= $Dialog->LargeHeader(title => $key);
    } else {
      $Temp = $Dialog->TextBox(
        name      => "FORM_".$key,
        value     => &Standard::HTMLize($SD::QUERY{'FORM_'.$key} || $in{'input'}->{'LANGUAGE'}->{$key}),
        subject   => $key
      );
    }

    if ($h == $#keys) {
      $Temp .= $Dialog->Button(
        buttons => [
          { type => "submit", value => "Modify" },
          { type => "reset", value => "Cancel" }
        ], join => "&nbsp;"
      );
    }
    $Body .= $Dialog->Dialog(body => $Temp);
  }
  
  $Body = $Dialog->Body($Body);
  $Body = $Dialog->Form(
    body    => $Body,
    hiddens => [
      { name => "SKIN", value => $SD::QUERY{'SKIN'} },
      { name => "LANGUAGE", value => $SD::QUERY{'LANGUAGE'} },
      { name => "action", value => "DoEditLanguage" },
      { name => "CP", value => "1" },
      { name => "Username", value => $SD::ADMIN{'USERNAME'} },
      { name => "Password", value => $SD::ADMIN{'PASSWORD'} }
    ]
  );
  $Body = $Dialog->Page(body => $Body);
  
  return $Body;
}

###############################################################################
# do subroutine
sub do {
  my $self = shift;

  #----------------------------------------------------------------------#
  # Printing page...                                                     #

  my $Dialog = HTML::Dialog->new();

  my $Body = $Dialog->Text(text => "The language file has been updated.");
     $Body = $Dialog->Dialog(body => $Body);
  
     $Body = $Dialog->SmallHeader(titles => "edit language").$Body;
     
     $Body = $Dialog->Body($Body);
     $Body = $Dialog->Page(body => $Body);
  
  return $Body;
}

1;