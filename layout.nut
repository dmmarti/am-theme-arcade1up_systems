////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////   

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below";
   </ label="Select wheel style", help="Select wheel style", options="gamewheel,listbox", order=4 /> enable_list_type="listbox";
   </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=5 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=6 /> transition_ms="25";  
   </ label="Wheel fade time", help="Time in milliseconds to fade the wheel.", options="Off,2500,5000,7500,10000", order=7 /> wheel_fade_ms="5000"; 
   </ label=" ", help=" ", options=" ", order=16 /> divider5="";
</ label="--------    Miscellaneous    --------", help="Miscellaneous options", order=17 /> uct6="select below";
   </ label="Enable random text colors", help=" Select random text colors.", options="Yes,No", order=18 /> enable_colors="Yes";
   </ label="Enable monitor static effect", help="Show static effect when snap is null", options="Yes,No", order=19 /> enable_static="No"; 
   </ label="Wheel Sounds", help="Play sounds when navigating games wheel", options="None,Simple,Random", order=25 /> enable_random_sound="Random";
}

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
//fe.layout.font="Roboto";

//for fading of the wheel
first_tick <- 0;
stop_fading <- true;
wheel_fade_ms <- 0;
try {	wheel_fade_ms = my_config["wheel_fade_ms"].tointeger(); } catch ( e ) { }

// modules
fe.load_module("fade");
fe.load_module( "animate" );

//////////////////////////////////////////////////////////////////////////////////
// Load the background layer using the DisplayName for matching 
local b_art = fe.add_image("bg.png", 0, 0, flw, flh );
local background = fe.add_image("bez.png", 0, 0, flw, flh )

//////////////////////////////////////////////////////////////////////////////////
// Video Preview or static video if none available
//create surface for snap
local surface_snap = fe.add_surface( 640, 480 );
local snap = FadeArt("snap", 0, 0, 640, 480, surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = true;

//now position and pinch surface of snap
//adjust the below values for the game video preview snap
surface_snap.set_pos(flx*0.575, fly*0.56, flw*0.35, flh*0.35);
surface_snap.skew_y = 0;
surface_snap.skew_x = 0;
surface_snap.pinch_y = 0;
surface_snap.pinch_x = 0;
surface_snap.rotation = 0;

//////////////////////////////////////////////////////////////////////////////////
local w_art = fe.add_image("wheel/[DisplayName]", flx*0.7, fly*0.0125, flw*0.175, flh*0.175 );
w_art.preserve_aspect_ratio=true;
w_art.alpha=255;

//////////////////////////////////////////////////////////////////////////////////
// The following section sets up what type and wheel and displays the users choice

if ( my_config["enable_list_type"] == "listbox" )
{
local listbox = fe.add_listbox( flx*0.012, fly*0.24, flw*0.47, flh*0.6 );
listbox.rows = 21;
listbox.charsize = 25;
listbox.set_rgb( 211, 211, 211 );
listbox.bg_alpha = 0;
listbox.align = Align.Centre;
listbox.selbg_alpha = 0;
listbox.sel_red = 255;
listbox.sel_green = 0;
listbox.sel_blue = 0;
//listbox.font = "moonhouse.ttf";

local g_art = fe.add_artwork("wheel", flx*0.115, fly*0.0125, flw*0.175, flh*0.175 );
g_art.preserve_aspect_ratio=true;
g_art.alpha=255;
}

//vertical wheel curved
if ( my_config["enable_list_type"] == "gamewheel" )
{
fe.load_module( "conveyor" );

local wheel_x = [ flx*0.11, flx*0.11, flx*0.11, flx*0.11, flx*0.11, flx*0.08, flx*0.11, flx*0.11, flx*0.11, flx*0.11, flx*0.11, flx*0.11, ]; 
local wheel_y = [ -fly*1.0, fly*0.0, fly*0.115, fly*0.155, fly*0.28, fly*0.365, fly*0.47, fly*0.55, fly*0.64, fly*0.75, fly*0.81, fly*1.0, ];
local wheel_w = [ flw*0.2, flw*0.2, flw*0.2, flw*0.2, flw*0.2, flw*0.275, flw*0.2, flw*0.2, flw*0.2, flw*0.2, flw*0.2, flw*0.2, ];
local wheel_h = [  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2, flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2, ];
local wheel_a = [  0,  200,  0,  200,  200,  255, 0,  200,  200,  0,  200,  0, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 7;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
                preserve_aspect_ratio = true;
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

conveyor <- Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}

// Play random sound when transitioning to next / previous game on wheel
function sound_transitions(ttype, var, ttime) 
{
	if (my_config["enable_random_sound"] == "Simple")
	{
		local sound_name = "selectclick.mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
	if (my_config["enable_random_sound"] == "Random")
	{
		local random_num = floor(((rand() % 1000 ) / 1000.0) * (124 - (1 - 1)) + 1);
		local sound_name = "sounds/GS"+random_num+".mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
}
fe.add_transition_callback("sound_transitions")

//////////////////////////////////////////////////////////////////////////////////
// Game information to show inside text box frame

//Title text info
local textt = fe.add_text( "[Title]", flx*0.525, fly*0.24, flw*0.45, flh*0.0275  );
textt.set_rgb( 225, 255, 255 );
//textt.style = Style.Bold;
textt.align = Align.Left;
textt.rotation = 0;
textt.word_wrap = false;

//Year text info
local texty = fe.add_text("Year: [Year]", flx*0.525, fly*0.29, flw*0.5, flh*0.0275 );
texty.set_rgb( 255, 255, 255 );
//texty.style = Style.Bold;
texty.align = Align.Left;

//Emulator text info
local textemu = fe.add_text( "System: [Emulator]", flx*0.525, fly*0.34, flw*0.5, flh*0.0275  );
textemu.set_rgb( 225, 255, 255 );
//textemu.style = Style.Bold;
textemu.align = Align.Left;
textemu.rotation = 0;
textemu.word_wrap = false;

//display filter info
local filter = fe.add_text( "Filter: [ListFilterName]", flx*0.525, fly*0.39, flw*0.5, flh*0.0275 );
filter.set_rgb( 255, 255, 255 );
//filter.style = Style.Italic;
filter.align = Align.Left;
filter.rotation = 0;

//display game info
local gamecount = fe.add_text( "Game Count: [ListEntry]-[ListSize]       Played Count: [PlayedCount]", flx*0.525, fly*0.44, flw*0.5, flh*0.0275 );
gamecount.set_rgb( 255, 255, 255 );
//gamecount.style = Style.Italic;
gamecount.align = Align.Left;
gamecount.rotation = 0;


// random number for the RGB levels
if ( my_config["enable_colors"] == "Yes" )
{
function brightrand() {
 return 255-(rand()/255);
}

local red = brightrand();
local green = brightrand();
local blue = brightrand();

// Color Transitions
fe.add_transition_callback( "color_transitions" );
function color_transitions( ttype, var, ttime ) {
 switch ( ttype )
 {
  case Transition.StartLayout:
  case Transition.ToNewSelection:
  red = brightrand();
  green = brightrand();
  blue = brightrand();
  //listbox.set_rgb(red,green,blue);
  texty.set_rgb (red,green,blue);
  textt.set_rgb (red,green,blue);
  textemu.set_rgb (red,green,blue);
  filter.set_rgb (red,green,blue);
  gamecount.set_rgb (red,green,blue);
  break;
 }
 return false;
 }
}

