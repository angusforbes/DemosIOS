#include "BlobThreshold.h"
#include "ContainerBlobInfo.h"

BlobThreshold::BlobThreshold(ContainerBlobInfo* _infoPanel, Color* startColor) {

  infoPanel = _infoPanel;
  InitializeThresholds(startColor);
}


void BlobThreshold::InitializeThresholds(Color* pixel) {
  
  printf("in BlobThreshold::UpdateThreshold\n");
 
  pixelRange = 30;
  UpdateThresholdColor(pixel);
    
  
  minDensity = 0.0;
  maxDensity = 1.0;
  minBlobSize = 0;
  maxBlobSize = 100; //should be called "maxBlobLength", since it is check w and h, not w*h
}


void BlobThreshold::UpdateThresholdColor(Color* pixel) {
  pixelColor = pixel;
  
  int inc = pixelRange;
  
  minRed = max(0,pixel->Red() - inc);
  maxRed = min(255,pixel->Red() + inc);
  minGreen = max(0,pixel->Green() - inc);
  maxGreen = min(255,pixel->Green() + inc);
  minBlue = max(0,pixel->Blue() - inc);
  maxBlue = min(255,pixel->Blue() + inc);
  
  int luma = pixel->Luma();
  minLuma = max(0,luma - inc);
  maxLuma = min(255,luma + inc);

}

void BlobThreshold::SetColorThresholds(vec3 min, vec3 max) {
  
  minRed = min.x;
  minGreen = min.y;
  minBlue = min.z;
  
  maxRed = max.x;
  maxGreen = max.y;
  maxBlue = max.z;
}
