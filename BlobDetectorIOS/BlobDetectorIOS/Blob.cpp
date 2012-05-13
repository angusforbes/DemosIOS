#include "Blob.h"

//#define INCLUSION_DISTANCE 30 //should be at least PIXEL_SKIP or PIXEL_SKIP * some multiple
//#define MAX_BLOB_WIDTH 250 //should be related to resolution of video
//#define MAX_BLOB_HEIGHT 250
//for blob made from a starting pixel seed
Blob::Blob(ivec2 pixel, int _inclusionPixelDistance, int _maxBlobSize) {

  numPixels = 0;
    left = pixel.x;
    right = pixel.x;
    bottom = pixel.y;
    top = pixel.y;
  
  maxBlobSize = _maxBlobSize;
  inclusionPixelDistance = _inclusionPixelDistance; //INCLUSION_DISTANCE;
    markedForRemoval = false;
}

//for merged blobs
Blob::Blob(ivec4 merged, int _numPixels, int _inclusionPixelDistance, int _maxBlobSize) {
  
  numPixels = _numPixels;
  left = merged.x;
  right = merged.y;
  bottom = merged.z;
  top = merged.w;
  maxBlobSize = _maxBlobSize;
  
  inclusionPixelDistance = _inclusionPixelDistance;
  markedForRemoval = false;
}

//just calculating the length, actually...
int Blob::CalculateSize() {
//  return ((right - left) + 1) * ((top - bottom) + 1);
  return fmax( GetHeight(), GetWidth());

}

int Blob::GetHeight() {
  return (top - bottom) + 1;
}

int Blob::GetWidth() {
  return (right - left) + 1;
}


ivec2 Blob::GetCentroid() {
  return ivec2(left + (right/2), bottom + top/2);
}


struct Comparator {
  //sorts other blobs by how close they are , closest to furthest
  
  ivec2 pt;
  Comparator(ivec2 pt) : pt(pt){};
  bool operator()(Blob* a, Blob* b) {
    return glm::distance(a->GetCentroid(), pt) < glm::distance(b->GetCentroid(), pt) ;
   // return  vec2::Distance(a->GetCentroid(), pt) < vec2::Distance(b->GetCentroid(), pt) ;
  }
  
  int* key;
};

Blob* Blob::GetClosestBlobToBlob( list<Blob*> blobs ) {
  
  blobs.sort(Comparator(GetCentroid()));
  
  list<Blob*>::iterator itA = blobs.begin();
  for(itA = blobs.begin(); itA != blobs.end(); ++itA) {
  
    if ( (*itA)->markedForChecking != true ) {
      (*itA)->markedForChecking = true;
      return (*itA);
    }
  }
    
  return NULL;
}


bool Blob::CompareBlobsBySize(  Blob* a,  Blob* b) {
  //sort from biggest size to smallest size
  return a->CalculateSize() > b->CalculateSize();
}

float Blob::CalculateDensity(int pixelSkip) {
  
  int w = (right - left) + 1;
  int h = (top - bottom) + 1;
  return fmin(1.0, ( (float) (numPixels * pixelSkip * pixelSkip )/ ((float) w*h)  ));
}

bool Blob::AddPixel(ivec2 pixel) {
  //printf("add %d/%d into %d/%d -> %d/%d? ...", pixel.x, pixel.y, left - inclusionPixelDistance,     bottom - inclusionPixelDistance,     right + inclusionPixelDistance,     top + inclusionPixelDistance);
  
  
  if (pixel.x <= left - inclusionPixelDistance || 
      pixel.x >= right + inclusionPixelDistance || 
      pixel.y <= bottom - inclusionPixelDistance || 
      pixel.y >= top + inclusionPixelDistance) 
  {
    return false;
  }
   
  
  int _left = fmin(pixel.x, left );
  int _right = fmax(pixel.x, right );
  int _bottom = fmin(pixel.y, bottom );
  int _top = fmax(pixel.y, top );
  
  //check if added pixel would make the height too high
  
  if ((_top - _bottom) > (top-bottom) && ((_top - _bottom) > maxBlobSize )) {
    //can't expand vertically
  //  printf("can't expand vertically!, top-bottom = %d > %d\n", (_top - _bottom), maxBlobSize);
    return false;
  }
 
  if ((_right - _left) > (right-left) && ((_right - _left) > maxBlobSize )) {
  //  printf("can't expand horizontally!, right-left = %d > %d\n", (_right - _left), maxBlobSize); 
    return false;
  }
  
//  
//  if (_top - _bottom > maxBlobSize || 
//      _right - _left > maxBlobSize) {
//    return false;
//  }
   
  left = _left;
  right = _right;
  bottom = _bottom;
  top = _top;
    
  numPixels++;
  
  return true; 
  
}



Blob* Blob::MergeBlobs(list<Blob*> checkBlobs, int _inclusionPixelDistance, int _maxBlobSize) {
  
  int numPixels = 0;
  //printf("\n\t Merging %lu Blobs!\n", checkBlobs.size());
  
  list<Blob*>::iterator it = checkBlobs.begin();
  (*it)->markedForRemoval = true;
  int left = (*it)->left;
  int right = (*it)->right;
  int bottom = (*it)->bottom;
  int top = (*it)->top;
  ++it;
  
  for(; it != checkBlobs.end(); ++it) {
    (*it)->markedForRemoval = true;
    
    //printf("merging blob %d %d %d %d into blob %d %d %d %d\n", left, right, bottom, top, (*it)->left, (*it)->right, (*it)->bottom, (*it)->top );
    
    left = fmin((*it)->left, left);
    right = fmax((*it)->right, right);
    bottom = fmin((*it)->bottom, bottom);
    top = fmax((*it)->top, top);
    numPixels += (*it)->numPixels;
  }
  
  //printf("MERGED blob %d %d %d %d\n", left, right, bottom, top);
  return new Blob(ivec4(left, right, bottom, top), numPixels, _inclusionPixelDistance, _maxBlobSize  );
}




  