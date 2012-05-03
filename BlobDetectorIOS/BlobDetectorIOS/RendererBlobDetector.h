
//#include "TextureCamera.hpp"
#include "Renderer.hpp" 

#ifndef RendererBlobDetector_hpp
#define RendererBlobDetector_hpp


class RendererBlobDetector : public Renderer {
  
public:
  void Initialize();
  void Draw();
  
 private:
  
//  RectInfo* testRect;
//  RectSlice* materialsRect;
//  Rectangle* infoRect;
  
  int cols;
  int rows;
  int slices;
  int textures;
  //int totalSlices;
  int textureWidth;
  int textureHeight;
  
  Texture** naturalTextures;
  
  vec3 rotVals; 
  vec3 transVals; 
  float scaleVal;
  mat4 MakeTextureMatrix();
 // TextureCamera* textureCamera;

  Geom* selectedGeom;

  
 //  bool ContainsWindowPoint(ivec2 windowPt);
   void HandleTouchMoved(ivec2 prevMouse, ivec2 mouse);
   void HandleTouchBegan(ivec2 mouse);
  void HandlePinchEnded();
  void HandlePinch(float scale);
  void HandleLongPress(ivec2 mouse);
  

};


#endif 

