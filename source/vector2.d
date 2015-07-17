module dung.vector2;

import std.math;

struct Vector2 {
	float x = 0.0;
	float y = 0.0;
	
	Vector2 opBinary(string op)(in Vector2 rhs) const
        if (op == "+" || op == "-")
    {
        return Vector2(mixin("x " ~ op ~ " rhs.x"), mixin("y" ~ op ~ " rhs.y"));
    }
    
    unittest {
		Vector2 a = Vector2(1, 2);
		Vector2 b = Vector2(3, 5);
		Vector2 c = a+b;
		Vector2 d = a-b;
		assert(c.x == 4);
		assert(c.y == 7);
		assert(d.x == -2);
		assert(d.y == -3);
	}

	Vector2 opBinary(string op)(in float rhs) const
        if (op == "*" || op == "/")
    {
        return Vector2(mixin("x " ~ op ~ " rhs"), mixin("y" ~ op ~ " rhs"));
    }

	ref Vector2 opOpAssign(string op)(in Vector2 rhs)
        if (op == "+" || op == "-")
    {
		mixin("x" ~ op ~ "= rhs.x;");
		mixin("y" ~ op ~ "= rhs.y;");
        return this;
    }

    unittest {
		Vector2 a = Vector2(1, 2);
		Vector2 b = Vector2(3, 5);
		Vector2 c = Vector2(7, 11);
		a+=c;
		b-=c;
		assert(a.x == 8);
		assert(a.y == 13);
		assert(b.x == -4);
		assert(b.y == -6);
	}

	ref Vector2 opOpAssign(string op)(in float rhs)
        if (op == "*" || op == "/")
    {
		mixin("x" ~ op ~ "= rhs;");
		mixin("y" ~ op ~ "= rhs;");
        return this;
    }
    
    float Length() const @property {
		return sqrt(LengthSquared);
	}
	
	float LengthSquared() const @property {
		return x*x+y*y;
	}
	
	unittest {
		Vector2 a = Vector2(3, 4);
		assert(a.Length == 5);
	}
	
	Vector2 Normalized() const @property {
		auto l = Length;
		if(l == 0) {
			return Vector2(0, 0);
		}
		return Vector2(x/l, y/l);
	}

	void Normalize() @property {
		auto l = Length;
		if(l > 0) {
			x = x/l;
			y = y/l;
		}
	}
}
