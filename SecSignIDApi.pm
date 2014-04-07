#!/usr/bin/perl -w
use strict;
use warnings;

#
#
# class AuthSession
#
#
package AuthSession;


# No State: Used when the session state is undefined. 
use constant NOSTATE => 0;

# Pending: The session is still pending for authentication.
use constant PENDING => 1;

# Expired: The authentication timeout has been exceeded.
use constant EXPIRED => 2;

# Accepted: The user was successfully authenticated.
use constant AUTHENTICATED => 3;

# Denied: The user denied this ticket.
use constant DENIED => 4;

# Suspended: The server suspended this session, because another authentication request was received while this session was still pending.
use constant SUSPENDED => 5;

# Canceled: The service has canceled this session.
use constant CANCELED => 6;

# Fetched: The device has already fetched the session, but the session hasn't been authenticated or denied yet.
use constant FETCHED => 7;

# Invalid: This session has become invalid.
use constant INVALID => 8;

#
# constructor
#
sub new
{
    my $class = shift;
    my $self  = bless {}, $class;
 
    return $self;
}

#
# gets secsign id assigned to ticket
#
sub getSecSignID
{
    my $self = shift;
    return $self->{secsignid};
}

#
# gets authentication session id assigned to ticket
#
sub getAuthSessionID
{
    my $self = shift;
    return $self->{authsessionid};
}

#
# gets requesting service name
#
sub getRequestingService
{
    my $self = shift;
    return $self->{service};
}

#
# gets requesting service address
#
sub getRequestingServiceAddress
{
    my $self = shift;
    return $self->{serviceaddr};
}

#
# gets request id assigned to auth session
#
sub getRequestID
{
    my $self = shift;
    return $self->{requestid};
}

#
# gets icon data which needs to be display
#
sub getIconData
{
    my $self = shift;
    return $self->{icondata};
}

#
# gets authentication session instance as hash reference
#
sub getAuthSessionAsHash
{
    my $self = shift;
    return {
        'secsignid' => $self->{secsignid},
        'authsessionid' => $self->{authsessionid},
        'service' => $self->{service},
        'serviceaddr' => $self->{serviceaddr},
        'requestid' => $self->{requestid},
        'icondata' => $self->{icondata}
    };
}

#
# creates authentication session instance from given hash reference
#
sub createAuthSessionFromHash
{
    my ($self, $hashref) = @_;
    
    $self->{secsignid}      = $hashref->{'secsignid'};
    $self->{authsessionid}  = $hashref->{'authsessionid'};
    $self->{service}        = $hashref->{'service'};
    $self->{serviceaddr}    = $hashref->{'serviceaddr'};
    $self->{requestid}      = $hashref->{'requestid'};
    $self->{icondata}       = $hashref->{'icondata'};
    
    return $self;
}

#
# return string representation
#
sub toString
{
    my $self = shift;
    #return sprintf("%s", $self);
    return $self->{requestid} . " (" . $self->{secsignid} . ", " . $self->{authsessionid} . ", " . $self->{service}  . ", " . $self->{serviceaddr}. ")";
}





#
#
# class SecSignIDApi
#
#
package SecSignIDApi;

# all use declaration
use URI::Escape;
use WWW::Curl::Easy;
use constant SCRIPT_REVISION => '$Revision: 1.7 $';

use constant FALSE => 0;
use constant TRUE  => 1;

#
# constructor
#
sub new
{
    my $class = shift;  # get class name
    my $self  = bless {}, $class; # declare $self instance
    my ($serverurl, $serverport, $fallbackserverurl, $fallbackserverport) = @_;
    
    # add given parameter
    $self->{secSignIDServer}              = "https://httpapi.secsign.com";
    $self->{secSignIDServerPort}          = 443;
    $self->{secSignIDServer_fallback}     = "https://httpapi2.secsign.com";
    $self->{secSignIDServerPort_fallback} = 443;
    
    # get script version and set referer, script version from cvs revision string
    my $firstSpace = index(SCRIPT_REVISION, ' ');
    my $lastSpace = rindex(SCRIPT_REVISION, ' ');
    my $version = substr(SCRIPT_REVISION, $firstSpace, ($lastSpace-$firstSpace));
    $version =~s/^\s+//; # trim leading whitespace
    $version =~s/\s+$//; # trim following whitespace
    
    $self->{scriptVersion} = $version;
    $self->{referer} = $class . "_Perl";
    $self->{pluginName} = undef;
    $self->{lastResponse} = undef;
    
    # return $self
    return $self;
}

#
# Sets an optional plugin name
#
sub setPluginName
{
    my ($self, $plName) = @_;
    $self->{pluginName} = $plName;
}

#
# Gets last response
#
sub getResponse
{
    my ($self) = @_;
    return $self->{lastResponse}
}

#
# Send query to secsigner id server to create a ticket for a certain secsigner-id. This method returns the ticket itself.
#
sub requestAuthSession
{
    my ($self, $secsignid, $servicename, $serviceadress) = @_;

    my $requestParameter = {
        'request'       => 'ReqRequestAuthSession', 
        'secsignid'     => $secsignid, 
        'servicename'   => $servicename,
        'serviceaddress'=> $serviceadress
    };
    
    if(defined($self->{pluginName})){
        $requestParameter->{'pluginname'} = $self->{pluginName};
    }
    
    my $requestQuery = $self->buildquery($requestParameter);
    
    # send query s request
    my $response = $self->sendRequest($requestQuery);
    my $responseHash = $self->checkResponse($response, TRUE); # will throw an exception in case of an error

    my $ticket = new MobileAuthTicket();
    $ticket->createTicketFromHash($responseHash);
    
    return $ticket;
}

#
# Gets the ticket state for a certain secsigner-id whether the ticket is still pending or it was accepted or denied.
#
sub getAuthSessionState
{
    my ($self, $authsession) = @_;
    
    my $requestParameter = {
        'request'       => 'ReqGetAuthSessionState', 
        
        'secsignid'     => $authsession->getSecSignID(), 
        'authsessionid' => $authsession->getAuthSessionID(),
        'requestid'     => $authsession->getRequestID()
    };
    
    my $requestQuery = $self->buildquery($requestParameter);
    
    # send query as request
    my $response = $self->sendRequest($requestQuery);
    my $resphash = $self->checkResponse($response, TRUE); # will throw an exception in case of an error
    
    return $resphash->{'authsessionstate'};
}

#
# Cancel the given authentication session
#
sub cancelAuthSession
{
    my ($self, $authsession) = @_;
    
    my $requestParameter = {
        'request'       => 'ReqCancelAuthSession', 
        
        'secsignid'     => $authsession->getSecSignerID(), 
        'authsessionid' => $authsession->getAuthSessionID(),
        'requestid'     => $authsession->getRequestID()
    };
    
    my $requestQuery = $self->buildquery($requestParameter);
    
    # send query as request
    my $response = $self->sendRequest($requestQuery);
    my $resphash = $self->checkResponse($response, TRUE); # will throw an exception in case of an error
       
    return $resphash->{'authsessionstate'};
}


#
# Releases the given authentication session
#
sub releaseAuthSession
{
    my ($self, $authsession) = @_;
    
    my $requestParameter = {
        'request'       => 'ReqReleaseAuthSession', 
        
        'secsignid'     => $authsession->getSecSignerID(), 
        'authsessionid' => $authsession->getAuthSessionID(),
        'requestid'     => $authsession->getRequestID()
    };
    
    my $requestQuery = $self->buildquery($requestParameter);
    
    # send query as request
    my $response = $self->sendRequest($requestQuery);
    my $resphash = $self->checkResponse($response, TRUE); # will throw an exception in case of an error
    
    return $resphash->{'authsessionstate'};
}

#
# sends given parameters to secsigner id server and wait given amount
# of seconds till the connection is timed out
#
sub sendRequest
{
    my $self  = shift @_;
    my $query = shift @_;
    my $timeout_in_seconds = 15;
    if(scalar(@_) > 0){
        $timeout_in_seconds = shift @_;
    }
    $timeout_in_seconds = 15 if($timeout_in_seconds < 1); # timeout has to be a positive value
    
    # create new curl instance/handle
    my $curl = new WWW::Curl::Easy;
    
    # set server and port
    $curl->setopt(CURLOPT_URL, $self->{secSignIDServer});
    $curl->setopt(CURLOPT_PORT, $self->{secSignIDServerPort});

    # return the transfer as a string
    # $curl->setopt(CURLOPT_RETURNTRANSFER, 1); # <- invention of PHP
    $curl->setopt(CURLOPT_HEADER, 0); # value 0 will strip header information in response 
    
    # set connection timeout
    $curl->setopt(CURLOPT_TIMEOUT,$timeout_in_seconds);
    $curl->setopt(CURLOPT_FRESH_CONNECT, 1);
    
    # make sure the common name of the certificate's subject matches the server's host name
    $curl->setopt(CURLOPT_SSL_VERIFYHOST, 2);

    # validate the certificate chain of the server
    $curl->setopt(CURLOPT_SSL_VERIFYPEER, TRUE);

    # set referer
    $curl->setopt(CURLOPT_REFERER, $self->{referer});

    # set connection timeout
    $curl->setopt(CURLOPT_POST, 2);
    $curl->setopt(CURLOPT_POSTFIELDS, $query);
    
    # response is stored in variable given as a reference
    my $response;
    $curl->setopt(CURLOPT_WRITEDATA, \$response);
    
    # actually send query
    my $ret = $curl->perform();
    
    $curl->cleanup();
    
    if($ret != 0){
        # set server and port
        $curl->setopt(CURLOPT_URL, $self->{secSignIDServer_fallback});
        $curl->setopt(CURLOPT_PORT, $self->{secSignIDServerPort_fallback});
        
        # response is stored in variable given as a reference
        $response = "";
        $curl->setopt(CURLOPT_WRITEDATA, \$response);
        
        # actually send query
        $ret = $curl->perform();
        $curl->cleanup();
        
        if($ret != 0){
            die("Could not connect to host: $ret " . $curl->strerror($ret) . " " . $curl->errbuf);
        }
    }
    
    $self->{lastResponse} = $response;
    return $response;
}

#
# checks the secsigner id server response string
#
sub checkResponse
{
    my ($self, $response, $throwExcIfError) = @_;

    if($response eq ''){
        if($throwExcIfError){
            die("could not connect to host '" . $self->{secSignerIDServer} . ":" . $self->{secSignerIDServerPort} . "'")
        }
    }
    
    my $responseHash = {};
    my @valuePairs = split(/&/, $response);

    foreach my $pair (@valuePairs)
    {
        my ($key, $value) = split(/=/, $pair, 2);
        $responseHash->{$key} = $value;
    }
    
    if(exists($responseHash->{'error'}))
    {
        if($throwExcIfError){
            die($responseHash->{'error'} . ": " . $responseHash->{'errormsg'});
        }
    }
    
    return $responseHash;
}

#
# build a hash with all parameters which has to be send to server
#
sub buildquery
{
    my ($self, $paramsHashRef) = @_;
    my $query = '';
    
    for (keys %$paramsHashRef)
    {
        $query .= $_ . '=' . uri_escape($paramsHashRef->{$_}) . '&';
    }
    
    $query .= 'apimethod'. '='. $self->{referer};
    #$query .= 'scriptversion'. '='. $self->{scriptVersion};
    
    return $query;
}


# close modul with obligatory 1
1;


__END__