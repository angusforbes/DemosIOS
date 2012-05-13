





#include "Rectangle.hpp"
#include "Container.hpp"
#include "Color.hpp"
#include <vector>
#include <list>


#ifndef OGRL_PixelList
#define OGRL_PixelList


#define GLM_SWIZZLE
#include <glm/glm.hpp>

 #include <glm/gtc/matrix_transform.hpp>
 #include <iostream> 
 #include <sstream>
 #include <glm/gtx/string_cast.hpp>
#include <glm/gtc/type_ptr.hpp>



class PixelList : public Rectangle { 
  
public:
  
  PixelList(Container* _c);
  void Draw();
  
  int numPixels; //for now, min=1, max=3
  int selectedPixel;
  bool pixel0_on;
  bool pixel1_on;
  bool pixel2_on;
  
  Color* pixel0;
  Color* pixel1;
  Color* pixel2;
  Color* borderColor;
  
  
  void HandleTouchBegan(ivec2 mouse); 
  void HandleTouchMoved(ivec2 prevMouse, ivec2 mouse); 
  void HandleTouchEnded(ivec2 mouse); 
  
//  float minVal;
//  float maxVal;
  
//  float handleW; 
//  float handleH; 
  bool isUpdated;
  void SetColor(Color* c) ;
  Container* container;
private:

  void DrawPixel(mat4 mv, Color* c);
  /*
  void DrawElement(mat4 mv, Color* color);
  void SetHandleModelViews();
  
  mat4 mvBk;
  mat4 mvMin;
  mat4 mvMax;
  
  bool minValSelected;
  bool maxValSelected;
  float offsetY;
  */
  Color* backgroundColor;
  
  
};

#endif
