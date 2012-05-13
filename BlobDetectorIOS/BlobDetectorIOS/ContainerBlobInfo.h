#include "Container.hpp"
#include "DoubleSlider.h"
#include "PixelList.h"
#include "BlobThreshold.h"

#ifndef ContainerBlobInfo_h
#define ContainerBlobInfo_h

class ContainerBlobInfo : public Container { 
  
public:
  
  ContainerBlobInfo();
  
  PixelList* pixelList;
  DoubleSlider* doubleSliderRed;
  DoubleSlider* doubleSliderGreen;
  DoubleSlider* doubleSliderBlue;
  DoubleSlider* doubleSliderSize;
  DoubleSlider* doubleSliderDensity;
  
  
  BlobThreshold* bt0;
  BlobThreshold* bt1;
  BlobThreshold* bt2;
  
  BlobThreshold* currentThreshold;
  //ivec4 selectedPixel;
 
  void UpdateCurrentThreshold(Color* pixel);
  
 // void SetColorThresholds(vec3 min, vec3 max);
  void UpdateSliderValues();
  void UpdateSliderValues(BlobThreshold* bt);
  /*
  void SetRed(int min, int max);
  ivec2 GetRed();
  void SetGreen(int min, int max);
  ivec2 GetGreen();
  void SetBlue(int min, int max);
  ivec2 GetBlue();
  */
    
  
  void Draw();

//  void HandleTouchBegan(ivec2 mouse); 
//  void HandleTouchMoved(ivec2 prevMouse, ivec2 mouse); 
  void InstallWidgets();
  void UpdateWidgets();
  
private:
  
};

#endif
