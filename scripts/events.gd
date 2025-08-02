extends Node

@warning_ignore_start("unused_signal")

# Menu events
signal request_main_menu
signal restart_current_level
signal switch_level(level_path: String)

# Run events
signal player_health_changed(amount: int)
signal player_speed_changed(speed: int)
signal player_died
signal radar_triggered
signal new_run_score(score: int)
signal new_highscore_reached(highscore: int)
signal trap_triggered(trap_xform: Transform3D)
signal boost_picked_up(boost_xform: Transform3D)
signal wall_hit
