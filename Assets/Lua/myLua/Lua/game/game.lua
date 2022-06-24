game = {}


game.services = {
	["player_service"]			= { path = "game.player.player_service";  			auto_start = true; };
	["update_service"]			= { path = "game.update.update_service";  			auto_start = true; };
}

game.service_manager = create_instance("framework.manager.service_manager")
game.scene_manager = create_instance("framework.manager.scene_manager")
game.sound_manager = create_instance("framework.sound.sound_manager")
game.event_dispatcher = create_instance("framework.event.event_dispatcher")

return game