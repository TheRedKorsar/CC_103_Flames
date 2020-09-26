// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Fire Effect
// Video: https://youtu.be/X0kjv0MozuY
// Algorithm: https://web.archive.org/web/20160418004150/http://freespace.virgin.net/hugo.elias/models/m_fire.htm

PGraphics buffer1;
PGraphics buffer2;
PGraphics buffer3;
PImage cooling;
int w = 600;
int h = 400;
int timer;
int name_cnt;

float ystart = 0.0;

ArrayList<Fire_text> txt_arr = new ArrayList<Fire_text>();

class Fire_text {
  int yPos = 0;
  int yMax = 150;
  int yInc = 2;
  String text = "";
  Fire_text(String txt){
    this.text = txt;
    yPos = 450;
  }
  void update(){
    yPos -= yInc;
    if (yPos > yMax){
      buffer1.beginDraw();
      buffer1.fill(255, 255, 255, 30);
      buffer1.noStroke();
      buffer1.textSize(72);
      buffer1.textAlign(CENTER, CENTER);
      buffer1.text(this.text, w/2, yPos);
      buffer1.endDraw();
    }
  }
}

void setup() {
  size(600, 400);
  buffer1 = createGraphics(w, h);
  buffer2 = createGraphics(w, h);
  buffer3 = createGraphics(w, h);
  cooling = createImage(w, h, RGB);
  txt_arr.add(new Fire_text("Inicialised"));
  name_cnt = 0;
}

color fire_gradient(float bright){
  if (bright>=0 && bright<25){
    return color(floor(map(bright, 0, 25, 29, 251)), floor(map(bright, 0, 25, 87, 243)), floor(map(bright, 0, 25, 118, 206)));
  }else if(bright>=25 && bright<100){
    return color(251, 243, 206);
  }else if(bright>=100 && bright<200){
    return color(floor(map(bright, 100, 200, 251, 181)), floor(map(bright, 100, 200, 243, 90)), floor(map(bright, 100, 200, 206, 9)));
  }else{
    return color(floor(map(bright, 200, 255, 181, 0)), floor(map(bright, 200, 255, 90, 0)), floor(map(bright, 200, 255, 9, 0)));
  }
}

void cool() {
  cooling.loadPixels();
  float xoff = 0.0; // Start xoff at 0
  float increment = 0.04;
  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  for (int x = 0; x < w; x++) {
    xoff += increment;   // Increment xoff 
    float yoff = ystart;   // For every xoff, start yoff at 0
    for (int y = 0; y < h; y++) {
      yoff += increment; // Increment yoff

      // Calculate noise and scale by 255
      float n = noise(xoff, yoff);     
      //float bright = pow(n, 2) * 30;
      float bright = n*10;

      // Try using this line instead
      //float bright = random(0,10);

      // Set each pixel onscreen to a grayscale value
      cooling.pixels[x+y*w] = color(bright);
    }
  }

  cooling.updatePixels();
  ystart += 0.1;
}

void fire(int rows) {
  buffer1.beginDraw();
  buffer1.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int j = 0; j < rows; j++) {
      int y = h-(j+1);
      int index = x + y * w;
      buffer1.pixels[index] = color(255);
    }
  }
  buffer1.updatePixels();
  buffer1.endDraw();
}

void mouseClicked() {
  txt_arr.add(new Fire_text( str(txt_arr.size())));
}
void check_new_names(){
  String[] lines = loadStrings("flist.txt");
  if (lines.length>name_cnt){
    name_cnt++;
    txt_arr.add(new Fire_text( lines[name_cnt-1]));
  }
}

void draw() {
  if (millis() - timer >= 2000) {
    check_new_names();
    timer = millis();
  }
  fire(5);
  for (int i = txt_arr.size()-1; i > -1 ; i--) { 
    Fire_text ft = txt_arr.get(i);
    ft.update();
    if (ft.yPos<ft.yMax){
      txt_arr.remove(i);
    }
  }
  cool();
  background(0);
  buffer2.beginDraw();
  buffer3.beginDraw();
  buffer1.loadPixels();
  buffer2.loadPixels();
  buffer3.loadPixels();
  for (int x = 1; x < w-1; x++) {
    for (int y = 1; y < h-1; y++) {
      int index0 = (x) + (y) * w;
      int index1 = (x+1) + (y) * w;
      int index2 = (x-1) + (y) * w;
      int index3 = (x) + (y+1) * w;
      int index4 = (x) + (y-1) * w;
      int index5 = 0;
      if (y > 1){
        index5 = (x) + (y-2) * w;
      }
      color c1 = buffer1.pixels[index1];
      color c2 = buffer1.pixels[index2];
      color c3 = buffer1.pixels[index3];
      color c4 = buffer1.pixels[index4];

      color c5 = cooling.pixels[index0];
      float newC = brightness(c1) + brightness(c2)+ brightness(c3) + brightness(c4);
      newC = newC * 0.25 - brightness(c5);

      buffer2.pixels[index5] = color(newC);
      buffer3.pixels[index5] = fire_gradient(255-newC);
    }
  }
  for (int y = 2; y < h; y++) {
    int x = 0;
    int index1 = (x) + (y-2) * w;
    int index2 = (y-1) * w - 1;
    buffer2.pixels[index1] = color(0);
    buffer2.pixels[index2] = color(0);
  }
  buffer2.updatePixels();
  buffer2.endDraw();
  buffer3.updatePixels();
  buffer3.endDraw();

  // Swap
  PGraphics temp = buffer1;
  buffer1 = buffer2;
  buffer2 = temp;

  image(buffer3, 0, 0);
  //image(cooling, w, 0);
}
