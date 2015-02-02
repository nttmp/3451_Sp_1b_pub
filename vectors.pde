//Simple Vector class for Project 1b
//Ryan Mendes

class Vector {
  double x;
  double y;
  double z;
  
  Vector() {
    x = 0;
    y = 0;
    z = 0;
  }
  
  Vector(double a, double b, double c){
    x = a;
    y = b;
    z = c;
  }
  
  double dotProduct(Vector other) {
    return (this.x * other.x) + (this.y * other.y) + (this.z * other.z);
  }
  
  Vector crossProduct(Vector other) { //Compute Cross Product by using determinent/"finger method"
    Vector cross = new Vector(this.y*other.z - other.y*this.z, (this.x*other.z - other.x*this.z)*(-1), this.x*other.y - other.x*this.y);
    println("crossProduct function: " + cross.print());
    return cross;
  }
  
  double magnitude() {
    return Math.sqrt((x*x) + (y*y) + (z*z));
  }
  
  void normalize() {
    double mag = this.magnitude();
    x /= mag;
    y /= mag;
    z /= mag;
  }
  
  String print() {
    String s = ("<" + this.x + ", " + this.y + ", " + this.z + ">");
    return s;
  }
  
}
