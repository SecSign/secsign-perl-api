#!/usr/bin/perl

#
# SecSign ID Api example in perl.
#
# (c) copyright SecSign Technologies Inc.
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
eval
{
    $authsession = $secSignIDApi->requestAuthSession($secsignid, $servicename);
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

eval
{
    my $authSessionState = $secSignIDApi->getAuthSessionState($authsession);
    
    print "auth session status is: " . $authSessionState . $/;
    print "pending status is " . AuthSession->PENDING . $/;
    print "fetched status is " . AuthSession->FETCHED . $/;
    
    if($authSessionState == AuthSession->AUTHENTICATED)
    {
        print "user has accepted the auth session '" . $authsession->getAuthSessionID() . "'." . $/;
        
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
