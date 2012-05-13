
//#include "Vector.hpp"
#include "Color.hpp"

#ifndef BlobDetectorIOS_BlobThreshold_h
#define BlobDetectorIOS_BlobThreshold_h

#define GLM_SWIZZLE
#include <glm/glm.hpp>
/*
 #include <glm/gtc/matrix_transform.hpp>
 #include <iostream> 
 #include <sstream>
 #include <glm/gtx/string_cast.hpp>
 */



using glm::ivec2;
using glm::vec2;
using glm::ivec4;
//using std::list;



class ContainerBlobInfo;
//#include "ContainerBlobInfo.h"


class BlobThreshold { 
  
public:
  
  BlobThreshold(ContainerBlobInfo* _infoPanel, Color* startColor);
  ContainerBlobInfo* infoPanel;
  
  void SetColorThresholds(vec3 min, vec3 max);
  //void SetPixelColor(Color* c);
  
  void InitializeThresholds(Color* pixel);
  void UpdateThresholdColor(Color* pixel);
  bool useColors; //if false, use Luma
  
  Color* pixelColor;
  
  int pixelRange;
  int minRed;
  int maxRed;
  int minGreen;
  int maxGreen;
  int minBlue;
  int maxBlue;
  int minLuma;
  int maxLuma;
  
  float minDensity;
  float maxDensity;
  int minBlobSize;
  int maxBlobSize;
  
  
  
private:
  
};

#endif

