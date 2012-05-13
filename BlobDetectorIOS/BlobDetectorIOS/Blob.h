//#include "Vector.hpp"
#include <vector>
#include <list>


#define GLM_SWIZZLE
#include <glm/glm.hpp>
/*
#include <glm/gtc/matrix_transform.hpp>
#include <iostream> 
#include <sstream>
#include <glm/gtx/string_cast.hpp>
*/

#ifndef VirtualDatasetsIOS_Blob_h
#define VirtualDatasetsIOS_Blob_h


using glm::ivec2;
using glm::vec2;
using glm::ivec4;
using std::list;

class Blob { 
  
public:
  
  Blob(ivec2 pixel, int _inclusionPixelDistance, int _maxBlobSize);
  Blob(ivec4 merged, int _numPixels, int _inclusionPixelDistance, int _maxBlobSize);
  
  
  int numPixels; ///use to calculate pixel density
  int left;
  int right;
  int top;
  int bottom;
  
  int inclusionPixelDistance;
  int maxBlobSize;
  
  bool AddPixel(ivec2 pixel);
  
  bool markedForRemoval;
  bool markedForChecking; //temp place, used for calculating nearest blob in prev frames
  
  
  int GetHeight();
  int GetWidth();
  
  Blob* GetClosestBlobToBlob( list<Blob*> prevBlobs );
  ivec2 GetCentroid();
  
  int CalculateSize();
  float CalculateDensity(int pixelSkip);
  
  static Blob* MergeBlobs(list<Blob*> checkBlobs, int _inclusionPixelDistance, int _maxBlobSize);
  static bool CompareBlobsBySize(Blob* a,  Blob* b);
private:
  
};



#endif
