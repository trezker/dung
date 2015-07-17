module dung.unit_control;

import dung.unit;
import dung.vector2;

import allegro5.allegro;

class Unit_control {
	Unit unit;
	bool move_up = false;
	bool move_down = false;
	bool move_left = false;
	bool move_right = false;
public:
	void Subject(Unit u) @property {
		unit = u;
	}
	
	Unit Subject() @property {
		return unit;
	}

	bool Consume_event(ALLEGRO_EVENT event) {
		switch(event.type) {
			case ALLEGRO_EVENT_KEY_DOWN: {
				switch(event.keyboard.keycode) {
					case ALLEGRO_KEY_UP: {
						move_up = true;
						break;
					}
					case ALLEGRO_KEY_DOWN: {
						move_down = true;
						break;
					}
					case ALLEGRO_KEY_LEFT: {
						move_left = true;
						break;
					}
					case ALLEGRO_KEY_RIGHT: {
						move_right = true;
						break;
					}
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_KEY_UP: {
				switch(event.keyboard.keycode) {
					case ALLEGRO_KEY_UP: {
						move_up = false;
						break;
					}
					case ALLEGRO_KEY_DOWN: {
						move_down = false;
						break;
					}
					case ALLEGRO_KEY_LEFT: {
						move_left = false;
						break;
					}
					case ALLEGRO_KEY_RIGHT: {
						move_right = false;
						break;
					}
					default:
				}
				break;
			}
			default:
		}
		return false;
	}
	
	void Update(float dt) {
		Vector2 v;
		v += Vector2(move_right, move_down);
		v -= Vector2(move_left, move_up);
		v.Normalize();
		unit.Velocity = unit.Velocity + v * dt;
	}
};
