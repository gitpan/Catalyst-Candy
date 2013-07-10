package Catalyst::Candy;
BEGIN {
  $Catalyst::Candy::AUTHORITY = 'cpan:GETTY';
}
{
  $Catalyst::Candy::VERSION = '0.001';
}
# ABSTRACT: Sugar for your Catalyst Components

use strict;
use warnings;
use Import::Into;

use namespace::autoclean ();
use Moose ();

sub import {

	my ( $class, @args ) = @_;
	my $target = caller;
	my $base = shift @args;
	if (grep { $base eq $_ } qw( Controller Model View )) {
		my $target_class = 'Catalyst::'.$base;
		Moose->import::into($target);
		$target->meta->superclasses($target_class);
		namespace::autoclean->import::into($target);
	}

	my $c;

	if ($target->meta->has_method('ACCEPT_CONTEXT')) {
		$target->meta->add_around_method_modifier('ACCEPT_CONTEXT',sub {
			my ( $orig, $self, $accept_context, @args ) = @_;
			$c = $accept_context;
			return $self->$orig($accept_context,@args);
		});
	} else {
		$target->meta->add_method('ACCEPT_CONTEXT',sub {
			my ( $self, $accept_context ) = @_;
			$c = $accept_context;
			return $self;
		});
	}

	my @new_functions = (
		c => sub { $c },
		session => sub { $c->session(@_) },
		stash => sub { $c->stash(@_) },
		param => sub { $c->req->param(@_) },
		params => sub { $c->req->params(@_) },
		req => sub { $c->req },
		res => sub { $c->res },
		args => sub { shift; shift; return(@_) },
		auth => sub { $c->authenticate(@_) },
		basic_auth => sub { $c->req->headers->authorization_basic(@_) },
		user => sub { $c->user(@_) },
		redirect => sub { $c->response->redirect(@_) },
		status => sub { $c->response->status(@_) },
		forward => sub { $c->forward(@_) },
		detach => sub { $c->detach(@_) },
		visit => sub { $c->visit(@_) },
		go => sub { $c->go(@_) },
		error => sub { $c->error(@_) },
		debug => sub { $c->debug },
		log => sub { my $func = shift; $c->log->$func(@_) },
		uri_for => sub { $c->uri_for(@_) },
		uri_for_action => sub { $c->uri_for_action(@_) },
		done => sub {
			Moose->unimport::out_of($target);
			$target->meta->make_immutable;
			return 1;
		},
	);
	while (@new_functions) {
		$target->meta->add_method(shift @new_functions,shift @new_functions);
	}

	my @around_functions = (
		config => sub {
			my $orig = shift;
			my $key = shift;
			$key eq $target
				? $target->$orig(@_)
				: $target->$orig($key,@_);
		},
	);
	while (@around_functions) {
		$target->meta->add_around_method_modifier(shift @around_functions,shift @around_functions);
	}

}

1;



__END__
=pod

=head1 NAME

Catalyst::Candy - Sugar for your Catalyst Components

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  package MyApp::Web::Controller::Root;

  use Catalyst::Candy qw( Controller );

  config namespace => '';

  sub base :Chained('/') :PathPart('') :CaptureArgs(0) {

    if ( my ( $username, $password ) = basic_auth ) {
      auth { username => $username, password => $password, };
    }

    stash title => 'hello';
    session session_var => 'value';

    stash some_var => user->admin;
    stash special => c->app_function;
    stash model_var => model('Bla')->func;

    error "Something bad happened" if param('error_maker');

  }

  ...

  sub end : Action {

    forward( view('TT') );

  }

  done; # equal to => no Moose; __PACKAGE__->meta->make_immutable;

=head1 DESCRIPTION

I will go to hell for this...

=encoding utf8

=head1 FUNCTIONS

=head2 config

  __PACKAGE__->config(@_)

=head2 c

  $c

=head2 session

  $c->session(@_)

=head2 stash

  $c->stash(@_)

=head2 param

  $c->req->param(@_)

=head2 params

  $c->req->params(@_)

=head2 req

  $c->req

=head2 res

  $c->res

=head2 args

  shift; shift; return(@_)

=head2 auth

  $c->authenticate(@_)

=head2 basic_auth

  $c->req->headers->authorization_basic(@_)

=head2 user

  $c->user(@_)

=head2 redirect

  $c->response->redirect(@_)

=head2 status

  $c->response->status(@_)

=head2 forward

  $c->forward(@_)

=head2 detach

  $c->detach(@_)

=head2 visit

  $c->visit(@_)

=head2 go

  $c->go(@_)

=head2 error

  $c->error(@_)

=head2 debug

  $c->debug

=head2 log

  my $func = shift; $c->log->$func(@_)

=head2 uri_for

  $c->uri_for(@_)

=head2 uri_for_action

  $c->uri_for_action(@_)

=head1 SEE ALSO

=over 4

=item L<Catalyst>

=back

=head1 SUPPORT

IRC

  Join #catalyst on irc.perl.org. Highlight Getty for fast reaction :).

Repository

  http://github.com/Getty/p5-catalyst-candy
  Pull request and additional contributors are welcome

Issue Tracker

  http://github.com/Getty/p5-catalyst-candy/issues

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

