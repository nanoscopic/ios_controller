#!/usr/bin/perl -w
use strict;

use LWP;
use JSON::PP qw/decode_json encode_json/;
use Data::Dumper;
use XML::Bare;

my $base = "http://192.168.2.8:8100";

my $agent = LWP::UserAgent->new();

#my $sid = session();
#print "Sid: $sid\n";

#source();
#apps_list();
#my $src = get_battery_info();
#my $sid = create_simple_session();
#window_size( $sid );
#control_center( $sid );

#home();

my $sid = create_simple_session();
#my $sid = 0;
toScreenRecording( $sid );

sub toScreenRecording {
  my $sid = shift;
  pressButton($sid,"home");
  pressButton($sid,"home");
  control_center( $sid );
  my $srId = el_by_name( $sid, 'Screen Recording' );
  if( !$srId ) {
    print "No screen rec - adding to control center\n";
    terminate( $sid, "com.apple.Preferences" );
    launch( $sid, "com.apple.Preferences" );
    
    sleep(1);
    
    my $root = sourceclean();
    my $offset = getoffset( 0, 0, $root, "ControlCenter", "" );
    scrollDownPx( $sid, $offset->[1] );
    my $searchEl = el_by_name( $sid, "Control Center" );
    if( !$searchEl ) {
      die "Could not find Control Center in Settings";
    }
    click( $sid, $searchEl );
    # Without this sleep the page transition from Settings to Control Centr
    #   is not finished and the XML source shows BOTH the Settings and Control Center
    #   -facepalm-
    sleep(1);
    
    my $root2 = sourceclean();
    my $offset2 = getoffset( 0, 0, $root2, "Insert Screen Recording", "" );
    scrollDownPx( $sid, $offset2->[1] );
    my $srAddId = el_by_name( $sid, "Insert Screen Recording" );
    click( $sid, $srAddId );
    
    pressButton($sid,"home");
    pressButton($sid,"home");
    control_center( $sid );
    $srId = el_by_name( $sid, 'Screen Recording' );
  }
  
}

#my $root = sourceclean();
#my $offset = getoffset( 0, 0, $root, "Insert Alarm", "", "" );
#my $offset = [0,758];
#print Dumper( $offset );
#scrollDownPx( $sid, $offset->[1] );



sub scrollDownPx {
  my ( $sid, $goDownPx ) = @_;
  print "Go down px: $goDownPx\n";
  my $size = window_size( $sid );
  my $screenHeight = $size->{height};
  print "Screen height: $screenHeight\n";
  #if( $goDownPx > ( $screenHeight / 2 ) ) { $goDownPx -= $screenHeight / 2; }
  my $maxScrollAtOnce = $screenHeight * 0.75;
  print "Max scroll at once: $maxScrollAtOnce\n";
  #print "Screens to scroll down $goDownScreens\n";
  my $toScroll = $goDownPx;
  my $midx = $size->{width} / 2;
  
  while( $toScroll > 0 ) {
    my $singleScroll = $toScroll;
    if( $toScroll > $maxScrollAtOnce ) {
      $singleScroll = $maxScrollAtOnce;
    }
    print "Single scroll: $singleScroll\n";
    
    return if( $singleScroll < 200 );
    my $starty = $size->{height} * 0.85;
    swipe_v_smooth( $sid, $midx, $starty, $starty - $singleScroll );
    #touch_perform( $sid, $midx, $starty, $midx, $starty - $singleScroll, 1000 );
    
    $toScroll -= $maxScrollAtOnce;
  }
}
#scroll_down( $sid, $settingsEl, $goDownChunks);#$offset->[1] ); 

# It is necessary to add up all the heights because the "y" offset given in the dumped
#   structure is essentially random so as to be useless.
# Adding up the heights doesn't work completely because element padding is not taken
#   into account ( nor is it present in the structure dump.
sub getoffset {
  my ( $x, $y, $node, $name ) = @_;
    
  my $aname = $node->{name} ? $node->{name}{value} : "";
  #print("$path $x $y $aname\n");
  if( $aname eq $name ) {
    #print Dumper( $node );
    return [ $x, $y ];
  }
  
  my $subs = getsubs( $node );
  
  for my $item ( @$subs ) {
    #next if( $item->{visible} && $item->{visible}{value} eq 'false' );
    my $res = getoffset( $x, $y, $item, $name );
    if( $res ) {
      return $res;
    }
    
    my $height = $item->{height} ? $item->{height}{value} : 0;
    $y += $height;
    #$hpath = "$hpath.$aname($height)";
  }
  return 0;  
}

sub getsubs {
  my $node = shift;
  
  my @subs;
  
  my $typ = ref( $node );
  return if( $typ ne 'HASH' );
  
  for my $key ( keys %$node ) {
    next if( $key =~ m/^_/ );
    my $sub = $node->{$key};
    my $subtyp = ref( $sub );
    next if( $subtyp eq 'HASH' && $sub->{_att} );
    if( $subtyp eq 'ARRAY' ) {
      for my $item ( @$sub ) {
        push( @subs, $item );
      }
      next;
    }
    next if( $subtyp ne 'HASH' );
    push( @subs, $sub );
  }
  
  @subs = sort { return $a->{_pos} <=> $b->{_pos} } @subs;
  return \@subs;
}
#my $sr = el_by_name( $sid, "Insert Screen Recording" );
#print("sr=$sr\n");
#scroll_to_visible( $sid, $sr ); # doesn't work. wtf.
#click( $sid, $sr ); #must use wda/tap/$eid
#rect( $sid, $sr );

#my $sid = create_session( "com.apple.Preferences" );


#my $sid = create_simple_session();
#print( "sid = $sid\n" );

#hidevent( $sid );
#quicktapn();

#siri( $sid, "enable assistive touch" );
#siri( $sid, "disable assistive touch" );
#siri( $sid, "increase volume" );
#siri( $sid, "decrease volume" );
#siri( $sid, "mute volume" );
#siri( $sid, "max volume" );
#siri( $sid, "show network settings" );
#siri( $sid, "show control center settings" );
#siri( $sid, "minimum brightness" );
#siri( $sid, "increase brightness" ); # 1/4 each time
#siri( $sid, "maximum brightness" );
#siri( $sid, "brightness 25 percent" );
#siri( $sid, "brightness 30 percent" );
#siri( $sid, "show accessibility settings" );
#siri( $sid, "enable light mode" );
#siri( $sid, "enable dark mode" );
#siri( $sid, "where am i" ); # has latitude and longitude
#siri( $sid, "where is my macbook" );
#siri( $sid, "where is my ipad" );
#siri( $sid, "who does this device belong to" );
#siri( $sid, "enable low power mode" );

#sendkeys( $sid, "ab" );
#tap_perform($sid, 300,150);
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
#control_center2( $sid );

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

sub quicktap {
  my ( $sid ) = @_;
  my $json = qq`{
    "x": 50,
    "y": 250
  }`;
  resp_to_val( $agent->post( "$base/session/$sid/wda/tap", 'Content-type' => 'application/json', Content => $json ) );
}

sub quicktapn {
  my $json = qq`{
    "x": 50,
    "y": 250
  }`;
  resp_to_val( $agent->post( "$base/wda/tap", 'Content-type' => 'application/json', Content => $json ) );
}

sub hidevent {
  my ( $sid ) = @_;
  # 0c-40 = activate siri
  # 0c-65 = take screenshot
  # 0c-e2 = mute/unmute
  my $json = qq`{
    "page": `.hex("0x07").qq`,
    "usage": `.hex("0x07").qq`,
    "duration": 0.05
  }`;
  resp_to_val( $agent->post( "$base/session/$sid/wda/performIoHidEvent", 'Content-type' => 'application/json', Content => $json ) );
    
  # /wda/performIoHidEvent
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
  #my ( $sid, $eid ) = @_;
  #my $resp = $agent->post( "$base/session/$sid/element/$eid/click", 'Content-type' => 'application/json', Content => '{}' );
  #print $resp->content;
  my ( $sid, $eid ) = @_;
  my $resp = $agent->post( "$base/session/$sid/wda/tap/$eid", 'Content-type' => 'application/json', Content => '{}' );
  print $resp->content;
}

sub rect {
  my ( $sid, $eid ) = @_;
  my $resp = $agent->get( "$base/session/$sid/element/$eid/rect" );
  my $content = $resp->content;
  print $content;
  return $content;
}

sub home {
  my $resp = $agent->post( "$base/wda/homescreen", 'Content-type' => 'application/json', Content => '{}' );
  print $resp->content;
}

sub launch {
  my ( $sid, $bundleId ) = @_;
  my $json = qq`{
    "bundleId": "$bundleId",
    "shouldWaitForQuiescence": false,
    "arguments": [],
    "environment": {}
  }`;

  my $resp = $agent->post( "$base/session/$sid/wda/apps/launch", 'Content-type' => 'application/json', Content => $json );
  print $resp->content;                                   
}

sub activate {
  my ( $sid, $bundleId ) = @_;
  my $json = qq`{
    "bundleId": "$bundleId"
  }`;

  my $resp = $agent->post( "$base/session/$sid/wda/apps/activate", 'Content-type' => 'application/json', Content => $json );
  print $resp->content;                                   
}

sub appState {
  my ( $sid, $bundleId ) = @_;
  my $json = qq`{
    "bundleId": "$bundleId"
  }`;

  my $resp = $agent->post( "$base/session/$sid/wda/apps/state", 'Content-type' => 'application/json', Content => $json );
  print $resp->content;                                   
}

sub terminate {
  my ( $sid, $bundleId ) = @_;
  my $json = qq`{
    "bundleId": "$bundleId"
  }`;

  my $resp = $agent->post( "$base/session/$sid/wda/apps/terminate", 'Content-type' => 'application/json', Content => $json );
  print $resp->content;                                   
}

sub pressButton {
  my ($sid,$name) = @_;
  my $resp = $agent->post( "$base/session/$sid/wda/pressButton", 'Content-type' => 'application/json', Content => "{\"name\":\"$name\"}" );
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
  print "sending $json\n";
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/keys", 'Content-type' => 'application/json', Content => $json ) );
  #print Dumper( $res );
}

sub siri {
  my ( $sid, $text ) = @_;
  my $ops = {
    text => $text
  };
  my $json = encode_json( $ops );
  print "sending $json\n";
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/siri/activate", 'Content-type' => 'application/json', Content => $json ) );
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

sub swipe_v_smooth {
  my ( $sid, $x, $y1, $y2 ) = @_;
  
  my $dif = $y2 - $y1; # if up, this is negative
  my $d1;
  my $d2;
  if( $dif < 0 ) {
    $d1 = $dif + 5;
    $d2 = -5;
  }
  
  print "Swiping from $x,$y1 to $x,$y2\n";
  my $json = qq`{
    "actions": [
      {
        "action": "press",
        "options": {
          "x":$x,
          "y":$y1
        }
      },
      { "action":"wait", "options": { "ms": 100 } },`;
      
  my $y = $y1 + $d1;
  $y = int( $y );
  $json .= qq`
    {
      "action": "moveTo",
      "options": {
        "x":$x,
        "y":$y
      }
    },
    { "action":"wait", "options": { "ms": 100 } },
  `;
  $y += $d2;
  $y = int( $y );
  $json .= qq`
    {
      "action": "moveTo",
      "options": {
        "x":$x,
        "y":$y
      }
    },
    { "action":"wait", "options": { "ms": 100 } },
  `;
      
  $json .= qq`
      {
        "action":"release",
        "options":{}
      }
    ]
  }`;
  print $json;
  my $res = resp_to_val( $agent->post( "$base/session/$sid/wda/touch/perform", 'Content-type' => 'application/json', Content => $json ) );
  print Dumper( $res );
}

sub touch_perform {
  my ( $sid, $x1, $y1, $x2, $y2, $delay ) = @_;
  $delay = 500 if( !$delay );
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
          "ms": $delay
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

sub tap_perform {
  my ( $sid, $x1, $y1 ) = @_;
  print "Tap at $x1,$y1\n";
  my $json = qq`{
    "actions": [
      {
        "action": "tap",
        "options": {
          "x":$x1,
          "y":$y1
        }
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

sub scroll_down {
  my ( $sid, $eid, $down ) = @_;
  my $json = qq`{
    "direction": "down",
    "distance": $down
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

sub create_simple_session {
  my $bundle = shift;
  my $json = qq`{
    "capabilities": {
      "alwaysMatch": {},
      "firstMatch": [
        {
          
        }
      ]
    }
  }`;
  my $res = resp_to_val( $agent->post( "$base/session", 'Content-type' => 'application/json', Content => $json ) );
  print Dumper( $res );
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

sub sourceclean {
  my $res = resp_to_val( $agent->get( "$base/source" ) );
  my ( $ob, $xml ) = XML::Bare->new( text => $res );
  print $ob->xml( $xml );
  return $xml;
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


