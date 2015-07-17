module dung.app;

import std.stdio;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_image;
import allegro5.allegro_color;
import allegro5.allegro_font;
import allegro5.allegro_ttf;

import dung.dungeon;
import dung.unit;
import dung.vector2;

int main(char[][] args) {
	return al_run_allegro({
		al_init();
		
		ALLEGRO_DISPLAY* display = al_create_display(800, 600);

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
		player.Radius = 0.5;
		Vector2 pos = dungeon.Get_spawn_point();
		player.Position = pos;
		writeln(player.Position);
		player.Color = ALLEGRO_COLOR(0, 0, 1, 1);
		float scale = 10;

		bool exit = false;
		while(!exit)
		{
			ALLEGRO_EVENT event;
			while(al_get_next_event(queue, &event))
			{
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
						//world.Update(0.02);
						break;
					}
					default:
				}
			}

			dungeon.Draw(scale);
			player.Draw(scale);
			al_flip_display();
			al_clear_to_color(ALLEGRO_COLOR(0.5, 0.25, 0.125, 1));
		}

		return 0;
	});
}
