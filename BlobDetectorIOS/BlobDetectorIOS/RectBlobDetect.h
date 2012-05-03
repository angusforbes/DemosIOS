#include "Rectangle.hpp"
#include "Circle.hpp"
#include <vector>
#include <list>

#include "Blob.h"
#include "FBO.hpp"

#ifndef VirtualDatasetsIOS_RectBlobDetect_h
#define VirtualDatasetsIOS_RectBlobDetect_h


class RectBlobDetect : public Rectangle { 
  
public:
  
  RectBlobDetect();
  void Draw();
  
  Blob* MergeBlobs(); //vector<Blob*> blobsToMerge);
  Texture* videoTexture;
  Texture* filterTexture;
  FBO* fbo;
 
  Circle* blobCircle;
  
  Rectangle* blobRect;
  list<Blob*> blobs;
  list<Blob*> checkBlobs;
  

  void HandleTouchBegan(ivec2 mouse); 
  void HandleTouchMoved(ivec2 prevMouse, ivec2 mouse); 
private:
  
  int minRed;
  int maxRed;
  int minGreen;
  int maxGreen;
  int minBlue;
  int maxBlue;
  int minLuma;
  int maxLuma;
  float minDensity;
  int minBlobSize;
  int maxBlobWidth;
  int maxBlobHeight;
  
  float wScale;
  float hScale;
  
  //vector<vec3> blobs;
  //vector<Blob*>& BlobDetect(Texture *t);
  void BlobDetect(Texture *t);
  bool PixelWithinRGBThresholds(ivec4 pixel);
  bool PixelWithinLumaThresholds(ivec4 pixel);
  bool CheckIfLegalBlob(Blob* b);
  mat4 CalculateCircleMV(Blob* b);
  mat4 CalculateRectMV(Blob* b);
  float AverageLuma(Texture* t, int skip);
  float RgbaToLuma(ivec4 rgba);
  mat4 ROT_MV;
};



#endif
