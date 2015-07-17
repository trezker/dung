module dung.dungeon;

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

Vector2[4] cardinal = [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(0, -1),
];

struct Tile {
	int region = 0;
	bool open = false;
	bool connection = false;
}

class Dungeon {
	Tile[][] tiles;
	int width = 79;
	int height = 59;
	int region = 0;
	
	void Init() {
		tiles = new Tile[][](width, height);
		Create_rooms();
		for(auto x = 1; x<width; x+=2) {
			for(auto y = 1; y<height; y+=2) {
				if(tiles[x][y].open) continue;
				Create_maze(x, y);
			}
		}
		region++;
		Create_connections();
		Remove_dead_ends();
	}
	
	void Remove_dead_ends() {
		for(auto x = 1; x<width-1; x+=2) {
			for(auto y = 1; y<height-1; y+=2) {
				auto cell = Vector2(x, y);
				while(true) 
				{
					auto open_sides = 0;
					Vector2 dir;
					foreach(c; cardinal) {
						if(Carved(cell + c)) {
							open_sides++;
							dir = c;
						}
					}
					if(open_sides != 1) break;
					Uncarve(cell);
					cell = cell+dir;
				}
			}
		}
	}
	
	void Create_connections() {
		Vector2[][int] connections;
		for(auto x = 1; x<width-1; x+=1) {
			for(auto y = 1; y<height-1; y+=1) {
				int conreg = min(tiles[x-1][y].region, tiles[x+1][y].region);
				if(tiles[x-1][y].region == tiles[x+1][y].region)
					conreg = 0;
				if(conreg == 0) {
					conreg = min(tiles[x][y-1].region, tiles[x][y+1].region);
					if(tiles[x][y-1].region == tiles[x][y+1].region)
						conreg = 0;
				}
				if(conreg == 0)
					continue;
				//tiles[x][y].connection = true;
				connections[conreg] ~= Vector2(x, y);
			}
		}
		foreach(c; connections) {
			Carve(c[uniform(0, c.length)]);
			Carve(c[uniform(0, c.length)]);
			foreach(p; c) {
				if(tiles[to!int(p.x)][to!int(p.y)].open == false)
					tiles[to!int(p.x)][to!int(p.y)].connection = false;
			}
		}
	}
	
	void Create_maze(int x, int y) {
		++region;
		tiles[x][y].open = true;
		tiles[x][y].region = region;
		
		Vector2 dir;
		Vector2[] cells;
		cells ~= Vector2(x, y);
		while(cells.length > 0) {
			Vector2 cell = cells[$-1];
			
			Vector2[] unmadeCells;
			
			foreach(c; cardinal) {
				if(Carvable(cell + c*2) == true) {
					unmadeCells ~= c;
				}
			}
			if(unmadeCells.length == 0) {
				//No open directions, remove the cell from list.
				cells = cells[0..$-1];
			}
			else {
				dir = unmadeCells[uniform(0, unmadeCells.length)];
				Carve(cell+dir);
				Carve(cell+dir*2);
				cells ~= cell+dir*2;
			}
		}
	}
	
	bool Carved(Vector2 v) {
		if(v.x > 0 && v.y > 0 && v.x < width && v.y < height && tiles[to!int(v.x)][to!int(v.y)].open == true) {
			return true;
		}
		return false;
	}

	bool Carvable(Vector2 v) {
		if(v.x > 0 && v.y > 0 && v.x < width && v.y < height && tiles[to!int(v.x)][to!int(v.y)].open == false) {
			return true;
		}
		return false;
	}
	
	void Carve(Vector2 p) {
		tiles[to!int(p.x)][to!int(p.y)].open = true;
		tiles[to!int(p.x)][to!int(p.y)].region = region;
	}

	void Uncarve(Vector2 p) {
		tiles[to!int(p.x)][to!int(p.y)].open = false;
		tiles[to!int(p.x)][to!int(p.y)].region = 0;
		//tiles[to!int(p.x)][to!int(p.y)].connection = true;
	}
	
	void Create_rooms() {
		auto room_min_size = 2;
		auto room_max_size = 6;
		auto room_attempts = 100;
		foreach(r; 0..room_attempts) {
			auto sx = uniform(room_min_size, room_max_size)*2+1;
			auto sy = uniform(room_min_size, room_max_size)*2+1;
			auto x = uniform(0, (width-sx)/2+1)*2;
			auto y = uniform(0, (height-sy)/2+1)*2;

			//Carve out the room
			bool overlap = false;
			foreach(tx; x..(x+sx)) {
				foreach(ty; y..(y+sy)) {
					if(tiles[tx][ty].region != 0) {
						overlap = true;
						break;
					}
				}
			}
			if(overlap)
				continue;
			++region;
			foreach(tx; x..(x+sx)) {
				foreach(ty; y..(y+sy)) {
					if(tx > x && tx < x+sx-1 && ty > y && ty < y+sy-1) {
						tiles[tx][ty].open = true;
						tiles[tx][ty].region = region;
					}
				}
			}
		}
	}
	
	void Draw(float scale, Vector2 camera_offset) {
		auto white = ALLEGRO_COLOR(1, 1, 1, 1);
		auto black = ALLEGRO_COLOR(0, 0, 0, 1);
		auto red = ALLEGRO_COLOR(1, 0, 0, 1);
		foreach(x; 0..(width)) {
			foreach(y; 0..(height)) {
				auto cx = x*scale-camera_offset.x;
				auto cy = y*scale-camera_offset.y;
				auto color = black;
				if(tiles[x][y].open)
					color = white;
				al_draw_filled_rectangle(cx, cy, cx+scale, cy+scale, color);
				if(tiles[x][y].connection)
					al_draw_filled_circle(cx+scale/2, cy+scale/2, scale/2, red);
			}
		}
	}
	
	Vector2 Get_spawn_point() {
		while(true) {
			auto p = Vector2(uniform(1, width-1), uniform(1, height-1));
			if(Carved(p)) {
				return p+Vector2(0.5, 0.5);
			}
		}
	}
}

