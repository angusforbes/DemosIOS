
#include "TextDemo.hpp"
#include "Rectangle3D.hpp"
#include "TextRect.hpp"




void TextDemo::Initialize() {
  
  //you can place a text object directly in the scene graph...
 
  
  //GetFont("CMUSerifUprightItalic60")->Bind(); {
  GetFont("Univers36")->Bind(); {
    //TextRect* t1 = new TextRect(GetFont("CMUSerifUprightItalic60"), "hello");
    TextRect* t1 = new TextRect("@@!@#hello");
    t1->SetTranslate(0.3,0,0);
    t1->SetHeight(0.15);
    t1->SetBackgroundColor(Color::Float(1.0,0,0,0.7));
    
    AddGeom(t1);
  }
  
}



float oY = 1.0;
int pX = 200;
int pY = 1100;
void TextDemo::Draw() { 
  
  //or you can add it directly to the window using object coords or pixels

  FontAtlas* font = GetFont("Univers128");
  font->Bind(); {
    Text(0, oY, "{0123456789}", Color::Float(1.0,0.0,0.0,0.9), false );
  } font->Unbind();
  
  font = GetFont("CMUSerifUprightItalic60");
  font->Bind(); {
    char s1[20];
    sprintf(s1, "object space %.02f", oY);
    Text(0.0, oY, s1, Color::Float(1.0,1.0,1.0,0.8) );
  
    char s2[20];
    sprintf(s2, "pixel space %d/%d", pX, pY);
    Text(pX, pY, s2, Color::Float(1.0,1.0,1.0,0.8), true );
    
  } font->Unbind();
  
  pY -= 3;
  if (pY < 0) {
    pY = 1100;
  }
  
  Text(GetFont("CMUSerifUprightItalic128"), 100, 100, "HEY!!!!!", Color::Float(0.0,0.0,1.0,1.0), true);
  
  
  oY -= 0.01;
  //    
  if (oY < -0.1) {
    oY = 1.0;
  }
  
  return;
  
}
