//CS 3451 Spring 2015
//Ryan Mendes
//Project 1b
//Last Saved 9:43

ArrayList<Matrix> matrixStack = new ArrayList<Matrix>();
ArrayList<Float> vertices = new ArrayList<Float>();
//Perspective Flags
boolean persp, ortho;
//Othographic frames
float fLeft, fRight, fBottom, fTop;
//Perspective field of view
float fieldOfView;


void gtInitialize() { 
  matrixStack.clear();
  matrixStack.add(identityMatrix());
}

void gtPushMatrix() { 
  if (matrixStack.size() < 10) {
  matrixStack.add(copyMatrix(matrixStack.get(matrixStack.size()-1)));
  }
  else println("!Stack size is 10!");
}

void gtPopMatrix() { 
  if (matrixStack.size() == 1) {
    println("!ERROR: only one matrix on the stack.!");
  }
  else matrixStack.remove(matrixStack.size()-1);
}

void gtOrtho(float left, float right, float bottom, float top) {
  //println("Ortho called");
  ortho = true;
  persp = false;
  fLeft = left;
  fRight = right;
  fBottom = bottom;
  fTop = top;
}

void gtPerspective(float fov) {
  //println("Persp called");
  persp = true;
  ortho = false;
  fieldOfView = radians(fov);
}

void gtBeginShape() { 
  vertices.clear();
}

void gtEndShape() { 
  for (int i = 0; i < vertices.size(); i+=4) { //TO DO: check this bro
    draw_line(vertices.get(i), vertices.get(i+1), vertices.get(i+2), vertices.get(i+3));
  }
  vertices.remove(0);
}

void gtVertex(float x, float y, float z) { 
  //Multiply by CTM
  Vector paramVector = new Vector(x, y, z);
  Vector transformVector = matrixVectorMult(matrixStack.get(matrixStack.size()-1), paramVector);
  //Do the perspective stuff
  if (ortho) {
    float newX = ((float)transformVector.x - fLeft) * (width / (fRight - fLeft));
    float newY = ((float)transformVector.y - fBottom) * (height / (fTop - fBottom));
    vertices.add(newX);
    vertices.add(newY);
  }
  else if (persp) {
    float k = (float)Math.tan(fieldOfView/2.0); // * Math.abs(z)?
    float xPrime = (float)transformVector.x / Math.abs((float)transformVector.z);
    float yPrime = (float)transformVector.y / Math.abs((float)transformVector.z);
    float xDoublePrime = (xPrime + k) * (width/(2.0*k));
    float yDoublePrime = (yPrime + k) * (height/(2.0*k));
    vertices.add(xDoublePrime);
    vertices.add(yDoublePrime);

//Gives Error... :/
//    float w = (float)Math.tan(fieldOfView/2.0) * Math.abs((float)transformVector.z);
//    float newX = ((float)transformVector.x) + w)/(2 * w)) * width;
//    float newY = ((float)transformVector.y + w/)(2 *w)) * height;
//    vertices.add(newX);
//    vertices.add(newY);
    
//Sabrina's
//    float w = (float) abs((float)transformVector.z) * tan(fieldOfView/2);
//    float xPrime = ((float) transformVector.x/w + 1) * width/2;
//    float yPrime = ((float) transformVector.y/w + 1) * height/2;
//    vertices.add(xPrime);
//    vertices.add(yPrime);

//Piazza
//    float k = (float)Math.tan(fieldOfView/2.0);
//    float newX = ((((float)transformVector.x)/Math.abs(z))+k) * (width/(2.0 * k));
//    float newY = ((((float)transformVector.y)/Math.abs(z))+k) * (height/(2.0 * k));
//    vertices.add(newX);
//    vertices.add(newY);
  }
}

/******************************************************************************
Transformations: These functions apply a transformation to the Current Transformation Matrix. Use the methods you wrote in the last project to do so.
******************************************************************************/

void gtTranslate(float tx, float ty, float tz) { 
  matrixStack.set(matrixStack.size()-1, matrixStack.get(matrixStack.size()-1).mult(Translate(tx, ty, tz))); 
}

void gtScale(float sx, float sy, float sz) { 
  matrixStack.set(matrixStack.size()-1, matrixStack.get(matrixStack.size()-1).mult(Scale(sx, sy, sz)));
}

void gtRotate(char axis, float theta) { 
  matrixStack.set(matrixStack.size()-1, matrixStack.get(matrixStack.size()-1).mult(Rotate(axis, theta)));
}

void gtRotate(float theta, float axisX, float axisY, float axisZ) {
  println("Paramters: " + axisX + " " + axisY + " " + axisZ);
  float floatTheta = (float)theta;
  Vector A = new Vector(axisX, axisY, axisZ);
  A.normalize();
  Vector N = new Vector(1.0, 0.0, 0.0);  
  if (A.dotProduct(N) == 1.0) { //Make sure that N is not parallel to A
    N = new Vector(0.0, 1.0, 0.0);
    if (A.dotProduct(N) == 1.0) {
      N = new Vector(0.0, 0.0, 1.0);
    }
  }

//Sabrina's
//  if (axisX == 0) {
//    N = new Vector(1.0,0.0,0.0);
//  } else {
//    N = new Vector(0.0,1.0,0.0);
//  }
  
  println("Vectors before:\nA: " + A.print() + " N: " + N.print());
  
  Vector B = A.crossProduct(N);
  println("Vectors After B = Cross(A,N):\nA: " + A.print() + " N: " + N.print() + " B: " + B.print());
  println("B mag: " + B.magnitude());
  B.normalize();
  Vector C = A.crossProduct(B);
  println("Vectors After C = Cross(A,N):\nA: " + A.print() + " N: " + N.print() + " B: " + B.print() + " C: " + C.print());
  println("C mag: " + C.magnitude());
  C.normalize();
  
  println("Vectors After All:\nA: " + A.print() + " N: " + N.print() + " B: " + B.print() + " C: " + C.print());
  
  Matrix R1 = identityMatrix();
  R1.m[0][0] = A.x;
  R1.m[0][1] = A.y;
  R1.m[0][2] = A.z;
  R1.m[1][0] = B.x;
  R1.m[1][1] = B.y;
  R1.m[1][2] = B.z;
  R1.m[2][0] = C.x;
  R1.m[2][1] = C.y;
  R1.m[2][2] = C.z;
  
  Matrix R2 = Rotate('x', theta);
  
  Matrix R3 = copyMatrix(R1);
  transposeMatrix(R3);
  
  println("Matrices:\nR1:\n" + R1.print() + " R2:\n" + R2.print() + " R3:\n" + R3.print());
  
  Matrix R3R2 = R3.mult(R2);
  Matrix R3R2R1 = R3R2.mult(R1);
  matrixStack.set(matrixStack.size()-1, matrixStack.get(matrixStack.size()-1).mult(R3R2R1));
  
//  Matrix R2R1 = R1.mult(R2);
//  Matrix RTR2 = R2R1.mult(R3);
//  matrixStack.set(matrixStack.size()-1, matrixStack.get(matrixStack.size()-1).mult(RTR2));

//  Matrix mult1 = matrixStack.get(matrixStack.size()-1).mult(R3);
//  Matrix mult2 = mult1.mult(R2);
//  Matrix mult3 = mult2.mult(R1);
//  matrixStack.set(matrixStack.size()-1, mult3);
  
  println("Coords: " + axisX + " " + axisY + " " + axisZ);

}


//*******Helper functions

//Matrix stuff

//Multiply a matrix by a vector
Vector matrixVectorMult(Matrix m, Vector v) {
  Matrix other = new Matrix();
  other.m[0][0] = v.x;
  other.m[1][0] = v.y;
  other.m[2][0] = v.z;
  other.m[3][0] = 1.0;
  other = m.mult(other);
  return new Vector(other.m[0][0], other.m[1][0], other.m[2][0]);
}

//Print all matrices in the stack
void printMatrixStack() { //Original param ArrayList<Matrix> stack
  println("Begin stack print:");
  for(int i = 0; i < matrixStack.size(); i++) {
    println(matrixStack.get(i).print());
  }
  println("End stack print.");
}

//Return an identity Matrix
Matrix identityMatrix() {
  Matrix I = new Matrix();
  I.m[0][0] = 1; I.m[1][1] = 1; I.m[2][2] = 1; I.m[3][3] = 1;
  return I;
}

//Make a copy of a matrix
Matrix copyMatrix(Matrix m){
  Matrix mCopy = new Matrix();
  for (int i = 0; i<4; i++){
    for (int j = 0; j<4; j++){
      mCopy.m[i][j] = m.m[i][j];
    }
  }  
  return mCopy;
}

//Return the transpose of a matrix
//Really crappily hardcoded approach
Matrix transposeMatrix(Matrix m){
  Matrix t = copyMatrix(m);
  m.m[0][1] = t.m[1][0];
  m.m[0][2] = t.m[2][0];
  m.m[0][3] = t.m[3][0];
  m.m[2][1] = t.m[1][2];
  m.m[3][1] = t.m[1][3];
  m.m[3][2] = t.m[2][3];
  m.m[1][0] = t.m[0][1]; //
  m.m[2][0] = t.m[0][2];
  m.m[3][0] = t.m[0][3];
  m.m[1][2] = t.m[2][1];
  m.m[1][3] = t.m[3][1];
  m.m[2][3] = t.m[3][2];
  
  return m; 
}

//********Old Stuff from 1a*************

//Input: is the scaling factor in each dimension
//Output: is the 4x4 scaling matrix
Matrix Scale(double sx, double sy, double sz){
  Matrix X = new Matrix();
  //your code here
  //Personal note: scaling factors go on the diagonal
  X.m[0][0] = sx;
  X.m[1][1] = sy;
  X.m[2][2] = sz;
  X.m[3][3] = 1;
  return X;
}

//Input: is the distance to translate in each dimension
//Output: is the 4x4 translation matrix
Matrix Translate(double x, double y, double z){
  Matrix X = new Matrix();
  //your code here
  //Personal note: translation factors are in the final column, with 1's on the diagonals
  X.m[0][3] = x;
  X.m[1][3] = y;
  X.m[2][3] = z;
  //Put 1's on the diagonal.
  for(int i = 0; i < 4; i++) {
    X.m[i][i] = 1;
  }
  return X;
}

//Input: "axis" is a character 'x', 'y', or 'z' denoting the axis about which to rotate
//Input: "theta" is the angle in degrees to rotate
//Output: is the 4x4 rotation matrix
Matrix Rotate(char axis, double theta){
  Matrix X = new Matrix();
//  float floatTheta = radians((float)theta);
  theta = (PI * theta)/180.0;
  float floatTheta = (float)theta;
//  println("floatTheta: " + floatTheta);
//  println("Cosine of Theta: " + cos(floatTheta));
//  println("Sine of Theta: " + cos(floatTheta));
  //Put 1's on the diagonal. Some of these will be overwritten of course.
  for(int i = 0; i < 4; i++) {
    X.m[i][i] = 1.0;
  }
  //The box is [C, -S, S, C] for X and Z, but is different for y.
  //For the axis being rotated about, it is a vector with 1 in the corresponding component and zeroes elsewhere.
  if(axis == 'x'){
    //your code here
    X.m[1][1] = (double)cos(floatTheta);
    X.m[1][2] = (double)sin(floatTheta) * -1.0;
    X.m[2][1] = (double)sin(floatTheta);
    X.m[2][2] = (double)cos(floatTheta);
  }else if(axis == 'y'){
    //your code here
    X.m[0][0] = (double)cos(floatTheta);
    X.m[2][0] = (double)sin(floatTheta) * -1.0;
    X.m[0][2] = (double)sin(floatTheta);
    X.m[2][2] = (double)cos(floatTheta);
  }else if(axis == 'z'){
    //your code here
    X.m[0][0] = (double)cos(floatTheta);
    X.m[0][1] = (double)sin(floatTheta) * -1.0;
    X.m[1][0] = (double)sin(floatTheta);
    X.m[1][1] = (double)cos(floatTheta);
  }else{
    println("invalid axis!");
  }
  return X;
}



