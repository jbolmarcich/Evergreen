#!/usr/bin/perl

#----------------------------------------------------------------
# Code for testing the container API
#----------------------------------------------------------------

require '../oils_header.pl';

my $config		= shift; 
my $username	= shift || 'admin';
my $password	= shift || 'open-ils';

osrf_connect($config);
oils_login($username, $password);
oils_fetch_session($authtoken);

my %types;
my $meth = 'open-ils.storage.direct.container';
$types{'biblio'}			= "biblio_record_entry_bucket";
$types{'callnumber'}		= "call_number_bucket";
$types{'copy'}				= "copy_bucket";
$types{'user'}				= "user_bucket";

# XXX These will depend on the data you have available.
# we need a "fetch_any" method to resolve this
$ttest{'biblio'}			= 40791;
$ttest{'callnumber'}		= 1;
$ttest{'copy'}				= 420795;
$ttest{'user'}				= 3;

my $testcopy = 420795;
my $testrec = 40791;
my $testcn = 1;
my $testuser = 3;

my %containers;
my %items;

containers_create();
#items_create();
containers_delete();

sub containers_create {

	for my $type ( keys %types ) {
		my $bucket = "Fieldmapper::container::" . $types{$type};
		$bucket = $bucket->new;
		$bucket->owner($user->id);
		$bucket->name("TestBucket");
		$bucket->btype("TestType");
	
		my $resp = simplereq($ACTOR, 
			'open-ils.actor.container.bucket.create',
			$authtoken, $type, $bucket );
	
		oils_event_die($resp);
		printl("Created new $type bucket with id $resp");
		$containers{$type} = $resp;
	}
}


sub items_create {
	for my $type ( keys %types ) {
		my $id = $containers{$type};

		my $item = "Fieldmapper::container::" . $types{$type} . "_item";
		$item = $item->new;

		$item->bucket($id);
		$item->target_copy($test{$type}) if $type eq 'copy';
		$item->target_call_number($test{$type}) if $type eq 'callnumber';
		$item->target_biblio_record_entry($test{$type}) if $type eq 'biblio';
		$item->target_user($test{$type}) if $type eq 'user';
	
		my $resp = simplereq($ACTOR, 
			'open-ils.actor.container.item.create',
			$authtoken, $type, $item );
	
		oils_event_die($resp);
		printl("Created new $type bucket item with id $resp");
		$items{$type} = $resp;
	}
}


sub items_delete {
	for my $type ( keys %types ) {
		my $id = $containers{$type};

		my $resp = simplereq($ACTOR, 
			'open-ils.actor.container.item.delete',
			$authtoken, $type, $id );
	
		oils_event_die($resp);
		printl("Deleted $type bucket item with id $id");
	}
}


sub containers_delete {
	for my $type (keys %containers) {
		my $id = $containers{$type};

		my $resp = simplereq( $ACTOR,
			'open-ils.actor.container.bucket.delete',
			$authtoken, $type, $id );

		oils_event_die($resp);
		printl("Deleted bucket $id");
	}
}
	

