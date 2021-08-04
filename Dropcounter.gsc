#include maps/mp/gametypes_zm/_hud_util;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;

init()
{
	level thread powerupdisplay();
	level thread nextpowerupdisplay();
}

powerupdisplay(){
	flag_wait( "initial_blackscreen_passed" );
	level.powerupcounter = 0;
	level.powerupdisplay = createServerFontString("hudsmall" , 1.3);
    level.powerupdisplay setPoint("LEFT", "TOP", -405, 20);
	level.powerupdisplay.label =& "Drops: ^4";
	for(;;){
		level.powerupdisplay setValue(level.powerupcounter);
		event = waittill_any_return("powerup_dropped", "start_of_round");
		if(event == "start_of_round"){
			level.powerupcounter = 0;
		} else {
			level.powerupcounter++;
		}
		if(level.powerupcounter >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ]){
			level.powerupdisplay.label =& "Drops: ^1";
		} else {
			level.powerupdisplay.label =& "Drops: ^4";
		}
	}
}

nextpowerupdisplay(){
	flag_wait( "initial_blackscreen_passed" );
	level.incrementdisplay = createServerFontString("hudsmall" , 1.3);
    level.incrementdisplay setPoint("LEFT", "TOP", -405, 35);
	level.incrementdisplay.label =& "Next Power Up: ^4";
	flag_wait( "start_zombie_round_logic" );
	flag_wait( "begin_spawning" );
	while(!isDefined(level.zombie_vars[ "zombie_powerup_drop_increment" ])){
		wait 0.05;
	}
	level.zombie_vars[ "zombie_powerup_drop_custom_increment" ] = level.zombie_vars[ "zombie_powerup_drop_increment" ];
	players = get_players();
	score_to_drop = ( players.size * level.zombie_vars[ "zombie_score_start_" + players.size + "p" ] ) + level.zombie_vars[ "zombie_powerup_drop_custom_increment" ];
	level.zombie_vars[ "zombie_powerup_drop_increment" ] = 9999999999999999.0;
	while(1){
		flag_wait("zombie_drop_powerups");
		players = get_players();
		curr_total_score = 0;
		i = 0;
		while( i < players.size ){
			if (isDefined(players[i].score_total)){
				curr_total_score += players[i].score_total;
			}
			i++;
		}
		if(curr_total_score > score_to_drop){
			level.zombie_vars[ "zombie_powerup_drop_custom_increment" ] *= 1.14;
			score_to_drop = curr_total_score + level.zombie_vars[ "zombie_powerup_drop_custom_increment" ];
			level.zombie_vars[ "zombie_drop_item" ] = 1;
		}
		if(level.zombie_vars[ "zombie_drop_item" ]){
			level.incrementdisplay setValue(0);
			level.incrementdisplay.label =& "Next Power Up: ^2";
		} else {
			if(level.powerupcounter >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ]){
				level.incrementdisplay.label =& "Next Power Up: ^1";
			} else {
				level.incrementdisplay.label =& "Next Power Up: ^4";
			}
			level.incrementdisplay setValue(score_to_drop - curr_total_score);
		}
		wait 0.5;
	}
}