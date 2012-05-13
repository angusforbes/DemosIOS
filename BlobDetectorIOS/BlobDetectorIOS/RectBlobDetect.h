#include "Rectangle.hpp"
#include "Circle.hpp"
#include <vector>
#include <list>

#include "Blob.h"
#include "FBO.hpp"
#include "ContainerBlobInfo.h"
#include "BlobThreshold.h"

#ifndef RectBlobDetect_h
#define RectBlobDetect_h


#define GLM_SWIZZLE
#include <glm/glm.hpp>

 
using glm::ivec2;
using glm::vec2;
using glm::ivec4;
using glm::mat4;
using std::list;


class RectBlobDetect : public Rectangle { 
  
public:
  
  RectBlobDetect();
  void Draw();
  
  //Blob* MergeBlobs(); //vector<Blob*> blobsToMerge);
  Texture* videoTexture;
  Texture* filterTexture;
  FBO* fbo;
 
  Circle* blobCircle;
  
  Rectangle* blobRect;
  list<Blob*> blobs;
  list<Blob*> checkBlobs;
  
   list<Blob*> prevBlobs;
  

  void HandleTouchBegan(ivec2 mouse); 
  void HandleTouchMoved(ivec2 prevMouse, ivec2 mouse); 
  
  void AttachController(ContainerBlobInfo* c);
  ContainerBlobInfo* infoPanel;  
  

private:
  
  void InitializeBlobShapes();
  void DetermineCurrentBlobs(BlobThreshold* bt);
  void DetermineLargestBlobs(BlobThreshold* bt, int maxNumBlobs);
  ivec2 pixelPt;
  bool pixelSelected;
  void HandleSelectedPixel();
  void ChooseSelectedPixel(ivec2 mouse);
//  int minRed;
//  int maxRed;
//  int minGreen;
//  int maxGreen;
//  int minBlue;
//  int maxBlue;
//  int minLuma;
//  int maxLuma;
//  float minDensity;
//  int minBlobSize;
//  int maxBlobWidth;
//  int maxBlobHeight;
  
  float wScale;
  float hScale;
  
  //vector<vec3> blobs;
  //vector<Blob*>& BlobDetect(Texture *t);
  void BlobDetect(Texture *t, BlobThreshold* bt);
  bool PixelWithinThresholds(ivec4 pixel, BlobThreshold* bt);
  bool PixelWithinRGBThresholds(ivec4 pixel,  BlobThreshold* bt);
  bool PixelWithinLumaThresholds(ivec4 pixel,  BlobThreshold* bt);
  bool CheckIfLegalBlob(Blob* b, BlobThreshold* bt);
  mat4 CalculateCircleMV(Blob* b);
  mat4 CalculateRectMV(Blob* b);
  int AverageLuma(Texture* t, int skip);
  mat4 ROT_MV;
};



#endif
