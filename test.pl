#!/usr/bin/perl -w
use strict;

use LWP;
use JSON::PP qw/decode_json/;
use Data::Dumper;

my $base = "http://10.0.0.140:8100";

my $agent = LWP::UserAgent->new();

#my $sid = session();
#print "Sid: $sid\n";

#source();
#apps_list();
#my $src = get_battery_info();
#window_size( $sid );
#control_center( $sid );

my $sid = create_session( "com.apple.Preferences" );
#my $sid = create_session( "com.dryark.vidtest2" );
#apps_list();

#my $devEl = el_by_name( $sid, 'Screen Recording' );
#force_touch( $sid, $devEl );

#my $devEl = el_by_name( $sid, 'vidtest2' );
#click( $sid, $devEl );

#my $devEl = el_by_name( $sid, 'Start Broadcast' );
#click( $sid, $devEl );

#click( $sid, $devEl );
#reset_media_services();
#start_broadcast( $sid, "vidtest2" );
control_center2( $sid );

sub start_broadcast {
  my ( $sid, $app_name ) = @_;
  $sid ||= session();
  control_center( $sid );
  my $devEl = el_by_name( $sid, 'Screen Recording' );
  force_touch( $sid, $devEl );
  $devEl = el_by_name( $sid, $app_name );
  click( $sid, $devEl );
  $devEl = el_by_name( $sid, 'Start Broadcast' );
  click( $sid, $devEl );
}

sub reset_media_services {
  my $sid = create_session( "com.apple.Preferences" );
  die "Could not create session for com.apple.Preferences" if( !$sid );
  my $devEl = el_by_name( $sid, 'Developer' );
  die "Could not find element Developer" if( !$devEl );
  
  #my $settingsPane = el_by_name( $sid, "Settings" );
  
  #scroll_to_name( $sid, $devEl, 'Developer' );
  scroll_to_visible( $sid, $devEl );
  click( $sid, $devEl );
  #force_touch( $sid, $devEl );
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

sub force_touch {
  my ( $sid, $eid ) = @_;
  my $json = qq`{
    "duration": 1,
    "pressure": 1000
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/element/$eid/forceTouch", 'Content-type' => 'application/json', Content => $json ) );
  #print Dumper( $res );
  #return $res->{'ELEMENT'};
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

sub control_center {
  my ( $sid ) = @_;
  my $size = window_size( $sid );
  my $midx = int( $size->{width} / 2 );
  my $maxy = $size->{height}-1;
  touch_perform( $sid, $midx, $maxy, $midx, $maxy - 100 ); 
}

sub control_center2 {
  my ( $sid ) = @_;
  my $size = window_size( $sid );
  my $maxx = $size->{width}-1;
  touch_perform( $sid, $maxx, 0, $maxx, 100 ); 
}

sub touch_perform {
  my ( $sid, $x1, $y1, $x2, $y2 ) = @_;
  print "Swiping from $x1,$y1 to $x2,$y2\n";
  my $json = qq`{
    "actions": [
      {
        "action": "press",
        "options": {
          "x":$x1,
          "y":$y1
        }
      },
      {
        "action":"wait",
        "options": {
          "ms": 500
        }
      },
      {
        "action": "moveTo",
        "options": {
          "x":$x2,
          "y":$y2
        }
      },
      {
        "action":"release",
        "options":{}
      }
    ]
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/touch/perform", 'Content-type' => 'application/json', Content => $json ) );
  print Dumper( $res );
}

sub launch_app {
  my ( $sid, $app ) = @_;
  print "Launching app $app\n";
  my $json = qq`{
    "bundleId": "$app",
    "shouldWaitForQuiescence": false,
    "arguments": [],
    "environment": []
  }`;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/apps/launch", 'Content-type' => 'application/json', Content => $json ) );
  print Dumper( $res );
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

sub window_size {
  my $sid = shift;
  $sid = session() if( !$sid );
  my $res = resp_to_val( $agent->get( "$base/session/$sid/window/size" ) );
  print Dumper( $res );
  return $res;
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


