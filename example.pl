#!/usr/bin/perl

# $Id: example.pl,v 1.8 2014/11/26 17:25:15 titus Exp $

#
# SecSign ID Api example in perl.
#
# (c) 2014 SecSign Technologies Inc.
#

use strict;
use warnings;

# add path where to look for modules. we assume that SecSignerIDConnector.pm is in same path
push(@INC , ".");

# load class definition
require SecSignIDApi;


# create new instance of SecSignerIDConnector class
my $secSignIDApi = new SecSignIDApi();


# the servicename is mandatory. it has to be send to the server.
# the value of $servicename will be shown on the display of the smartphone. 
# the user then can decide whether he accepts the auth session shown also on his mobile phone.
my $servicename = "Your Website Login";
my $serviceaddress = "http://www.yoursite.com/";
my $secsignid   = "username";

# get auth session
my $authsession;
my $authSessionState;
eval
{
    $authsession = $secSignIDApi->requestAuthSession($secsignid, $servicename, $serviceaddress);
    print "got auth session '" . $authsession->toString() . "'" . $/;
} 
or do 
{
    # an exception is thrown using die
    print "could not get an auth session for secsign id '" . $secsignid . "' :" . $@ . $/;
    exit();  
};

if(! defined($authsession)){
    print "could not get an auth session for secsign id '" . $secsignid . "'" . $/;
    exit();
}


my $noerror = 0;

eval {
	$authSessionState = $secSignIDApi->getAuthSessionState($authsession);
} or do {
	$noerror = 1;
};
print "auth session has state $authSessionState$/";
	
while($noerror == 0 && ($authSessionState == AuthSession->PENDING || $authSessionState == AuthSession->FETCHED)) {

	# sleep for couple of seconds
	sleep 5;
	    
	eval {
    	$authSessionState = $secSignIDApi->getAuthSessionState($authsession);
    } or do {
		# an exception is thrown using die
		print "could not check state of auth session for secsign id '" . $secsignid . "' :" . $@ . $/;
		exit();  
	};
	print "auth session has state $authSessionState$/";
}

eval
{
    print "auth session state is: " . $authSessionState . $/;
    if($authSessionState == AuthSession->AUTHENTICATED)
    {
        print "user has accepted the auth session '" . $authsession->getAuthSessionID() . "'." . $/;
        
        $secSignIDApi->releaseAuthSession($authsession);
        print "auth session '" . $authsession->getAuthSessionID() . "' was released." . $/;
    }
    elsif($authSessionState == AuthSession->DENIED)
    {
        print "user has denied the auth session '" . $authsession->getAuthSessionID() . "'." . $/;
        
        $secSignIDApi->releaseAuthSession($authsession);
        print "auth session '" . $authsession->getAuthSessionID() . "' was released." . $/;
    }
    else
    {
        $secSignIDApi->cancelAuthSession($authsession);
        print "canceled auth session..." . $/;
    }
} 
or do 
{
    # an exception is thrown using die
    print "could not cancel auth session for secsign id '" . $secsignid . "' :" . $@ . $/;
    exit();  
};


__END__
