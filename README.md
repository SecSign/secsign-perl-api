# SecSign ID Perl Interface


**Overview**

SecSign ID Api is a two-factor authentication for perl web applications.

This Perl API allows a secure login using a private key on a smart phone running SecSign ID by SecSign Technologies Inc.


**Usage**

* Include the API `SecSignIDApi.pm` in your project.
* Request an authentication session
* Show access pass to user and save session parameters 
* Get session state 
* React to the state and have the user logged in


Check out the included example `example.pl` to see how it works or 
have a look at the how to use tutorial for PHP <https://www.secsign.com/php-tutorial/>. The process is exactly the same in perl.
or visit <https://www.secsign.com> for more informations.

**Files**

* `SecSignIDApi.pm` - the file contains two packages SecSignIDApi and AuthSession. The functions in package SecSignIDApi will care about the communication with the ID server
* `example.pl` - a small test script


**Prerequisites**

To use the SecSign ID perl interface the module `curl` needs to be available. To be more exact, the interface uses thge module `WWW::Curl::Easy`.
Either you load the CURL module from CPAN <http://search.cpan.org/~szbalint/WWW-Curl-4.17/lib/WWW/Curl.pm> and put it into the local directory from which you will run the perl interface.

Propably after the module was downloaded it needs to be installed. Unzip the package and run following commands:

* `perl Makefile.pl`
* `make`
* `make test`
* `make install`

It is important to do this as superuser or administrator. It is also important to check for the newest Curl module version from CPAN archive. Otherwise there are some side effects on some os.

Or you install the CURL module via CPAN:

* to start the CPAN shell: `sudo perl -MCPAN -e shell`
* to upgrade and configure CPAN: `sudo perl -MCPAN -e 'install Bundle::CPAN'`
* to install the module: `sudo perl -MCPAN -e 'install WWW::Curl::Easy'`


===============

SecSign Technologies Inc. official site: <https://www.secsign.com>