module dung.app;

import std.stdio;
import std.conv;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_image;
import allegro5.allegro_color;
import allegro5.allegro_font;
import allegro5.allegro_ttf;

import dung.dungeon;
import dung.unit;
import dung.unit_control;
import dung.vector2;

int main(char[][] args) {
	return al_run_allegro({
		al_init();
		
		Vector2 resolution = Vector2(800, 600);
		ALLEGRO_DISPLAY* display = al_create_display(to!int(resolution.x), to!int(resolution.y));

		al_install_keyboard();
		al_install_mouse();
		al_init_image_addon();
		al_init_font_addon();
		al_init_ttf_addon();
		al_init_primitives_addon();

		ALLEGRO_TIMER *timer = al_create_timer(0.02);
		al_start_timer(timer);

		ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
		al_register_event_source(queue, al_get_display_event_source(display));
		al_register_event_source(queue, al_get_keyboard_event_source());
		al_register_event_source(queue, al_get_mouse_event_source());
		al_register_event_source(queue, al_get_timer_event_source(timer));

		Dungeon dungeon = new Dungeon;
		dungeon.Init();

		Unit player = new Unit;
		player.Radius = 0.2;
		Vector2 pos = dungeon.Get_spawn_point();
		player.Position = pos;
		player.Color = ALLEGRO_COLOR(0, 0, 1, 1);
		float scale = 64;
		
		Unit_control control = new Unit_control;
		control.Subject = player;

		Vector2 camera_offset;

		bool exit = false;
		while(!exit)
		{
			ALLEGRO_EVENT event;
			while(al_get_next_event(queue, &event))
			{
				control.Consume_event(event);
				switch(event.type)
				{
					case ALLEGRO_EVENT_DISPLAY_CLOSE:
					{
						exit = true;
						break;
					}
					
					case ALLEGRO_EVENT_KEY_DOWN:
					{
						switch(event.keyboard.keycode)
						{
							case ALLEGRO_KEY_ESCAPE:
							{
								exit = true;
								break;
							}
							case ALLEGRO_KEY_T:
							{
								break;
							}
							default:
						}
						break;
					}
					case ALLEGRO_EVENT_TIMER:
					{
						control.Update(0.02);
						player.Update(0.02);
						if(dungeon.Carved(player.Position+Vector2(player.Radius, 0)) == false) {
							player.Position = Vector2(to!int(player.Position.x)+1-player.Radius, player.Position.y);
							player.Velocity = Vector2(0, player.Velocity.y);
						}
						if(dungeon.Carved(player.Position-Vector2(player.Radius, 0)) == false) {
							player.Position = Vector2(to!int(player.Position.x)+player.Radius, player.Position.y);
							player.Velocity = Vector2(0, player.Velocity.y);
						}
						if(dungeon.Carved(player.Position+Vector2(0, player.Radius)) == false) {
							player.Position = Vector2(player.Position.x, to!int(player.Position.y)+1-player.Radius);
							player.Velocity = Vector2(player.Velocity.x, 0);
						}
						if(dungeon.Carved(player.Position-Vector2(0, player.Radius)) == false) {
							player.Position = Vector2(player.Position.x, to!int(player.Position.y)+player.Radius);
							player.Velocity = Vector2(player.Velocity.x, 0);
						}
						Corner_collision(Vector2(1, 1), player, dungeon);
						Corner_collision(Vector2(-1, 1), player, dungeon);
						Corner_collision(Vector2(-1, -1), player, dungeon);
						Corner_collision(Vector2(1, -1), player, dungeon);

						camera_offset = player.Position*scale - resolution/2;
						break;
					}
					default:
				}
			}

			dungeon.Draw(scale, camera_offset);
			player.Draw(scale, camera_offset);
			al_flip_display();
			al_clear_to_color(ALLEGRO_COLOR(0.5, 0.25, 0.125, 1));
		}

		return 0;
	});
}

void Corner_collision(Vector2 corner, ref Unit unit, Dungeon dungeon) {
	auto zcorner = Vector2(corner.x, corner.y);
	if(zcorner.x<0)zcorner.x=0;
	if(zcorner.y<0)zcorner.y=0;
	auto c = Vector2(to!int(unit.Position.x)+zcorner.x, to!int(unit.Position.y)+zcorner.y);
	auto v = c-unit.Position;
	if(dungeon.Carved(unit.Position+corner) == false && v.Length < unit.Radius) {
		unit.Position = c-v.Normalized*unit.Radius;
	}
}
