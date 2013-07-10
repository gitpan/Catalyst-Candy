package MyCatalystCandyTestController;

use Catalyst::Candy qw( Controller );

config namespace => '';

sub base :Chained('/') :PathPart('') :CaptureArgs(0) {

	if ( my ( $username, $password ) = basic_auth ) {
		auth { username => $username, password => $password };
	}

	stash array_var => [ 'array' ];
	stash var => "value";

}

sub index :Chained('base') :PathPart('') :Args(0) {

	stash title => 'Index';

}

sub default :Chained('base') :PathPart('') :Args {

	stash title => 'Not Found';
	status 404;

}

sub end : ActionClass('RenderView') {

	forward(view('TT'));

}

done;