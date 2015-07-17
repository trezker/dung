module dung.unit;

import std.conv;
import std.stdio;
import std.random;
import std.algorithm;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_image;
import allegro5.allegro_color;
import allegro5.allegro_font;
import allegro5.allegro_ttf;

import dung.vector2;

class Unit  {
	Vector2 pos;
	Vector2 vel;
	double rad;
	ALLEGRO_COLOR color = ALLEGRO_COLOR(1, 0, 0, 1);
	
	void Draw(float scale) {
		al_draw_filled_circle(pos.x*scale, pos.y*scale, rad*scale, color);
	}

	void Update(double dt) {
		pos += vel*dt;
	}

	double Radius() const @property {
		return rad;
	}
	
	void Radius(double r) @property {
		rad = r;
	}

	Vector2 Position() const @property {
		return pos;
	}
	
	void Position(Vector2 p) @property {
		pos = p;
	}

	Vector2 Velocity() const @property {
		return vel;
	}
	
	void Velocity(Vector2 p) @property {
		vel = p;
	}

	ALLEGRO_COLOR Color() const @property {
		return color;
	}
	
	void Color(ALLEGRO_COLOR c) @property {
		color = c;
	}
}
