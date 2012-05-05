

#include "RendererBlobDetector.h"
#include "Rectangle3D.hpp"
#include "Rectangle.hpp"
#include "Geom.hpp"
#include "TextRect.hpp"
#include "Cube.hpp"
#include "RectBlobDetect.h"
#include "ContainerBlobInfo.h"

float cameraZ;

void RendererBlobDetector::Initialize() {    
  
  
  /*
  Rectangle* r = new Rectangle();
  r->SetColor(1,0,0,1);
  r->SetTranslate(0.0, 0.3);
  
  r->SetSize(1.0, 0.7);
  r->IsSelectable = true;  
  AddGeom(r);
 */
  
  
  
  ContainerBlobInfo* info = new ContainerBlobInfo();
  info->SetColor(new Color(vec4(0.0,0.0,0.0,1.0)));
  info->SetScale(1.0, 0.3);
  AddGeom(info);
  
  RectBlobDetect* rbd = new RectBlobDetect();
  rbd->SetTranslate(0.0,0.3);
  //rbd->SetScaleAnchor(0.5, 0.5);
  rbd->SetScale(1,.7);
  rbd->IsSelectable = true;
  AddGeom(rbd);

  rbd->AttachController(info);
  
  
  
  /*
  int numSliders = 3;
  
  float sliderInc = (1.0/numSliders);
  
  for (int i = 0; i < numSliders; i++) {
  Rectangle* doubleSlider1 = new Rectangle();
  doubleSlider1->SetTranslate( sliderInc * i, 0);
  doubleSlider1->SetColor(0,0,0.3*i,1);
  doubleSlider1->SetSize(sliderInc, 1.0);
    doubleSlider1->IsSelectable = true;  
  r2->AddGeom(doubleSlider1);
  
  }
  */
  
}


void RendererBlobDetector::Draw() { 
}

 


void RendererBlobDetector::HandleTouchBegan(ivec2 mouse) {
  
  ivec2 um = ivec2(mouse.x, height - mouse.y);
  printf("height = %d, mouse then um\n", height);
  mouse.Print("mouse = ");
  um.Print("adjusted mouse = ");
  
  vector<Geom*> gcwp = GetGeomsContainingWindowPoint(mouse); //may need to use (um) in real device
  
  printf("we found %lu geoms containing the mouse touch\n", gcwp.size());
  if (gcwp.size() > 0) {
    selectedGeom = gcwp[gcwp.size() - 1]; //this will return one of the more deeply nested, need to do something smarter to get smallest or closest to camera.
    
    cout << "geom at " << selectedGeom->GetTranslate().String() << " contains mouse point!\n";
    selectedGeom->HandleTouchBegan(mouse);
  
  } else {
    selectedGeom = NULL;
  }
}

void RendererBlobDetector::HandleTouchEnded(ivec2 mouse) {
  if (selectedGeom != NULL) {
    selectedGeom->HandleTouchEnded(mouse);
  }
} 
void RendererBlobDetector::HandleTouchMoved(ivec2 prevMouse, ivec2 mouse) {
  if (selectedGeom != NULL) {
    selectedGeom->HandleTouchMoved(prevMouse, mouse);
  }
}

void RendererBlobDetector::HandlePinch(float scale) {
  if (selectedGeom != NULL) {
    selectedGeom->HandlePinch(scale);
  }
}

void RendererBlobDetector::HandlePinchEnded() {
  if (selectedGeom != NULL) {
    selectedGeom->HandlePinchEnded();
  }
}

void RendererBlobDetector::HandleLongPress(ivec2 mouse) {
  if (selectedGeom != NULL) {
    selectedGeom->HandleLongPress(mouse);
  }
}

/*
    

  
  //REAL ONE //think about...
  if (ResourceHandler::GetResourceHandler()->IsUsingGyro()) {
    transVals.y+=(mouse.y - prevMouse.y) * .001;
    transVals.x+=(mouse.x - prevMouse.x) * .001;
  } else {
    rotVals.x+=(mouse.y - prevMouse.y) * .2;
    rotVals.y+=(prevMouse.x - mouse.x) * .2;
  }
  
  //  tc->moveCamX((prevMouse.x - mouse.x) * .002);
  //  
  //  tc->moveCamY((mouse.y - prevMouse.y) * .002);
  //  tc->Transform();
  //CheckScale();
}
*/

//void RendererBlobDetector::Draw() {}
//bool RendererBlobDetector::ContainsWindowPoint(ivec2 windowPt) { return false; }


