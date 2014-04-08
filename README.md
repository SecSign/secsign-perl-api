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
have a look at the how to use tutorial for PHP <https://secsign.com/en/php-integrate-tutorial.html>. The process is exactly the same in perl.
or visit <https://www.secsign.com> for more informations.

**Files**

* `SecSignIDApi.pm` - the file contains two packages SecSignIDApi and AuthSession. The functions in package SecSignIDApi will care about the communication with the ID server
* `example.pl` - a small test script


===============

SecSign Technologies Inc. official site: <https://www.secsign.com>