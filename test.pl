#!/usr/bin/perl -w
use strict;

use LWP;
use JSON::PP qw/decode_json/;
use Data::Dumper;

my $base = "http://localhost:8100";

my $agent = LWP::UserAgent->new();

#my $sid = get_session_id();
#print "Sid: $sid\n";

#source();
#get_apps_list();
#my $src = get_battery_info();

#my $sid = create_session( "com.apple.Preferences" );
#my $devEl = el_by_name( $sid, 'General' );
#click( $sid, $devEl );
reset_media_services();

sub reset_media_services {
  my $sid = create_session( "com.apple.Preferences" );
  die "Could not create session for com.apple.Preferences" if( !$sid );
  my $devEl = el_by_name( $sid, 'Developer' );
  die "Could not find element Developer" if( !$devEl );
  
  #my $settingsPane = el_by_name( $sid, "Settings" );
  
  #scroll_to_name( $sid, $devEl, 'Developer' );
  scroll_to_visible( $sid, $devEl );
  click( $sid, $devEl );
  #sleep(2);
  #print "Done sleep\n";
  
  #my $searchEl = el_by_name( $sid, "Settings" );
  #print("Search element: $searchEl\n");
  #set_value( $sid, $searchEl, "media" );
  #scroll( $sid, $searchEl );
  #click( $sid, $searchEl );
  #sendkeys( $sid, "media" );
  #source( $sid );
  
  #swipeDown( $sid );
  #sendkeys( $sid, "media" );
  #click( $sid, $devEl );
  apps_list( $sid );
  my $resetEl = el_by_name( $sid, 'Reset Media Services' );
  scroll_to_visible( $sid, $resetEl );
  sleep(1);
  click( $sid, $resetEl );
  sleep(1);
  
  delete_session( $sid );
}

sub el_by_name {
  my ( $sid, $name ) = @_;
  my $json = qq`{
    "using": "name",
    "value": "$name"
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/element", 'Content-type' => 'application/json', Content => $json ) );
  return $res->{'ELEMENT'};
}

sub set_value {
  my ( $sid, $eid, $value ) = @_;
  my $json = qq`{
    "value" => "$value"
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/element/$eid/value", 'Content-type' => 'application/json', Content => $json ) );
}

sub el_by_type {
  my ( $sid, $name ) = @_;
  my $json = qq`{
    "using": "type",
    "value": "$name"
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/element", 'Content-type' => 'application/json', Content => $json ) );
  return $res->{'ELEMENT'};
}

sub click {
  my ( $sid, $eid ) = @_;
  my $resp = $agent->post( "$base/session/$sid/element/$eid/click", 'Content-type' => 'application/json', Content => '{}' );
  print $resp->content;
}

sub focuse {
  my ( $sid, $eid ) = @_;
  my $resp = $agent->post( "$base/session/$sid/wda/element/$eid/focuse" );
  print $resp->content;
  #print Dumper( $res );
}

sub tap {
  my ( $sid, $eid ) = @_;
  my $resp = $agent->post( "$base/session/$sid/wda/tap/$eid", 'Content-type' => 'application/json', Content => '{"x":5,"y":5}' );
  print $resp->content;
  #print Dumper( $res );
}

sub sendkeys {
  my ( $sid, $text ) = @_;
  my $ops = {
    value => [ split('',$text) ]
  };
  my $json = encode_json( $ops );
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/keys", 'Content-type' => 'application/json', Content => $json ) );
  #print Dumper( $res );
}

sub swipeDown {
  my ( $sid ) = @_;
  my $json = qq`{
    "direction": "up"
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/element/0/swipe", 'Content-type' => 'application/json', Content => $json ) );
  #print Dumper( $res );
}

sub scroll_to_name {
  my ( $sid, $eid, $name ) = @_;
  my $json = qq`{
    "name": "$name"
  }`;
  my $resp = $agent->post( "$base/session/$sid/wda/element/$eid/scroll", 'Content-type' => 'application/json', Content => $json );
  print Dumper( $resp );
}

sub scroll_to_visible {
  my ( $sid, $eid ) = @_;
  my $json = qq`{
    "toVisible": 1
  }`;
  my $resp = $agent->post( "$base/session/$sid/wda/element/$eid/scroll", 'Content-type' => 'application/json', Content => $json );
  print $resp->content;
}

sub scroll_dir_dist {
  my ( $sid, $eid, $dir, $dist ) = @_;
  my $json = qq`{
    "direction": "$dir",
    "distance": "$dist"
  }`;
  my $resp = $agent->post( "$base/session/$sid/wda/element/$eid/scroll", 'Content-type' => 'application/json', Content => $json );
  print $resp->content;
}

sub delete_session {
  my $sid = shift;
  my $resp = $agent->delete( "$base/session/$sid" );
  print $resp->content;
}

sub create_session {
  my $bundle = shift;
  my $json = qq`{
    "capabilities": {
      "alwaysMatch": {
          "arguments": [],
          "bundleId": "$bundle",
          "environment": {},
          "shouldUseSingletonTestManager": true,
          "shouldUseTestManagerForVisibilityDetection": false,
          "shouldWaitForQuiescence": false
      },
      "firstMatch": [
        {
          
        }
      ]
    }
  }`;
  my $res = resp_to_val( $agent->post( "$base/session", 'Content-type' => 'application/json', Content => $json ) );
  #print Dumper( $res );
  return $res->{'sessionId'};
}

sub session {
  my $resp = $agent->get( "$base/status" );
  #print $resp->status_line;
  my $content = decode_json( $resp->content );
  my $sid = $content->{'sessionId'};
  return $sid;
}

sub source {
  my $res = resp_to_val( $agent->get( "$base/source" ) );
  print Dumper( $res );
}

sub apps_list {
  my $sid = shift;
  $sid = session() if( !$sid );
  my $res = resp_to_val( $agent->get( "$base/session/$sid/wda/apps/list" ) );
  print Dumper( $res );
}

sub battery_info {
  my $sid = session();
  my $res = resp_to_val( $agent->get( "$base/session/$sid/wda/batteryInfo" ) );
  print Dumper( $res );
}

sub resp_to_val {
  my $resp = shift;
  my $rawContent = $resp->content;
  return {} if( $rawContent !~ m/^\{/ );
  my $content = decode_json( $rawContent );
  return $content->{value} || $content;
}


