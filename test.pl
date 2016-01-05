use strict;
use warnings;

use Data::Dumper;
use lib '/root/cPanel-PublicAPI/lib';
use cPanel::PublicAPI ();

use lib '/usr/local/cpanel';
use Cpanel::Security::Authn::TwoFactorAuth::Google ();

# Root user - accesshash auth
#my $api = cPanel::PublicAPI->new( 'ssl_verify_mode' => 0, 'debug' => 1 );
#my $resp = $api->whm_api('applist');
#print Dumper $resp;
#$resp = eval { $api->whm_api('fakecall'); };
#print Dumper $resp;
#$resp = eval { $api->whm_api('fakecall', { 'api.version' => 0 }); };
#print Dumper $resp;

# Reseller - without 2fa configured
# Note that the 'security tokens' in the URLs is different for the whm call, and the cpanel call
#my $api2 = cPanel::PublicAPI->new( 'ssl_verify_mode' => 0, 'user' => 'asder', 'pass' => 'blah1', 'debug' => 1 );
#my $resp2 = $api2->whm_api( 'applist', { 'api.version' => 0 } );
#print Dumper $resp2;
#$resp2 = $api2->cpanel_api2_request( 'cpanel', { 'user' => 'asder', 'module' => 'MysqlFE', 'func' => 'listdbs' }, {} );
#print Dumper $resp2;
#$resp2 = eval { $api2->cpanel_api2_request( 'cpanel', { 'user' => 'asder', 'module' => 'Fake', 'func' => 'fake' }, {} ) };
#print Dumper $resp2;

#$resp2 = $api2->cpanel_api1_request( 'cpanel', { 'user' => 'asder', 'module' => 'Mysql', 'func' => 'listdbs' }, [] );
#print Dumper $resp2;
#$resp2 = eval { $api2->cpanel_api1_request( 'cpanel', { 'user' => 'asder', 'module' => 'Fake', 'func' => 'Fake' }, [] ) };
#print Dumper $resp2;

# Reseller - with 2fa configured
my $google_auth = Cpanel::Security::Authn::TwoFactorAuth::Google->new(
    {
        'account_name' => 'cptest',
        'secret'       => 'USYWQGBP54JX3WHK',
        'issuer'       => 'issuer name'
    }
);
my $api3 = cPanel::PublicAPI->new( 'ssl_verify_mode' => 0, 'user' => 'cptest', 'pass' => 'blahblah', 'error_log' => '/dev/null' );
my $resp3;
eval { $resp3 = $api3->whm_api( 'applist', { 'api.version' => 0 } ); };
print "WHM Request for a 2FA account without a 2fa session failed. Reason returned: $@\n" if $@;
# Establish a 2fa session and then do the call and see it succeeds
$api3->establish_tfa_session('whostmgr', $google_auth->generate_code());
eval { $resp3 = $api3->whm_api( 'applist', { 'api.version' => 0 } ); };
print "WHM request after establishing 2FA session successful.\n" if !$@;
#print Dumper $resp3;
#undef $resp3;

## Crossing realms without establishing a tfa session for the new realm, fails:
#eval { $resp3 = $api3->cpanel_api2_request( 'cpanel', { 'user' => 'cptest', 'module' => 'MysqlFE', 'func' => 'listdbs' }, {} ) };
#print "cPanel request for a 2FA account without a 2fa session failed. Reason returned: $@\n" if $@;
## establish tfa session for the new realm, and see call is successful
#$api3->establish_tfa_session('cpanel', $google_auth->generate_code());
#eval { $resp3 = $api3->cpanel_api2_request( 'cpanel', { 'user' => 'cptest', 'module' => 'MysqlFE', 'func' => 'listdbs' }, {} ) };
#print "cPanel request after establishing 2FA session successful.\n" if !$@;
#print Dumper $resp3;
