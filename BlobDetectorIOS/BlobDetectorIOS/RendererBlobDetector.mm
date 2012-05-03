

#include "RendererBlobDetector.h"
#include "Rectangle3D.hpp"
#include "Rectangle.hpp"
#include "Geom.hpp"
#include "TextRect.hpp"
#include "Cube.hpp"
#include "RectBlobDetect.h"

float cameraZ;

void RendererBlobDetector::Initialize() {    
  RectBlobDetect* rbd = new RectBlobDetect();
  rbd->SetTranslate(0.5,0.5);
  rbd->SetScaleAnchor(0.5, 0.5);
  rbd->SetScale(1,1);
  rbd->IsSelectable = true;
  AddGeom(rbd);
}


void RendererBlobDetector::Draw() { 
}

 


void RendererBlobDetector::HandleTouchBegan(ivec2 mouse) {
  
  ivec2 um = ivec2(mouse.x, height - mouse.y);
  printf("height = %d, mouse then um\n", height);
  mouse.Print("mouse = ");
  um.Print("adjusted mouse = ");
  
  vector<Geom*> gcwp = GetGeomsContainingWindowPoint(um);
  
  printf("we found %lu geoms containing the mouse touch\n", gcwp.size());
  if (gcwp.size() > 0) {
    selectedGeom = gcwp[gcwp.size() - 1]; //this will return one of the more deeply nested, need to do something smarter to get smallest or closest to camera.
    
    cout << "geom at " << selectedGeom->GetTranslate().String() << " contains mouse point!\n";
    selectedGeom->HandleTouchBegan(mouse);
  
  } else {
    selectedGeom = NULL;
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


