#include "DoubleSlider.h"
#include "Camera.hpp"

#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

DoubleSlider::DoubleSlider(Container* _c) {
  container = _c;
  minVal = 0.25;
  maxVal = 0.75;  
  
  handleW = 0.95;
  handleH = 0.1;
  
  backgroundColor = NULL;
}

void DoubleSlider::SetHandleModelViews() {
  
  
  mvBk = glm::mat4(GetModelView());
  mvBk = glm::translate(mvBk, vec3(0.5,(maxVal + minVal)/2.0,0.0));
  mvBk = glm::scale(mvBk, vec3(handleW,maxVal-minVal,1.0));
  mvBk = glm::translate(mvBk, vec3(-0.5,-0.5,0.0));
  
  mvMin = glm::mat4(GetModelView());
  mvMin = glm::translate(mvMin, vec3(0.5,minVal,0.0));
  mvMin = glm::scale(mvMin, vec3(handleW,handleH,1.0));
  mvMin = glm::translate(mvMin,vec3( -0.5,-0.5,0.0 ));
  
  mvMax = glm::mat4(GetModelView());
  mvMax = glm::translate(mvMax, vec3( 0.5,maxVal,0.0) );
  mvMax = glm::scale(mvMax, vec3(handleW,handleH,1.0) );
  mvMax = glm::translate(mvMax, vec3(-0.5,-0.5,0.0));  
/*
  mvBk = mat4(GetModelView());
  mvBk = mat4::Translate(mvBk, 0.5,(maxVal + minVal)/2.0,0.0);
  mvBk = mat4::Scale(mvBk, handleW,maxVal-minVal,1.0);
  mvBk = mat4::Translate(mvBk, -0.5,-0.5,0.0);
  
  mvMin = mat4(GetModelView());
  mvMin = mat4::Translate(mvMin, 0.5,minVal,0.0);
  mvMin = mat4::Scale(mvMin, handleW,handleH,1.0);
  mvMin = mat4::Translate(mvMin, -0.5,-0.5,0.0);
  
  mvMax = mat4(GetModelView());
  mvMax = mat4::Translate(mvMax, 0.5,maxVal,0.0);
  mvMax = mat4::Scale(mvMax, handleW,handleH,1.0);
  mvMax = mat4::Translate(mvMax, -0.5,-0.5,0.0); 
 */
}

void DoubleSlider::DrawElement(mat4 mv, Color* color) {
 
  Program* p = GetProgram("FlatShader");
    p->Bind(); {
      glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, glm::value_ptr(mv));
      glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));
    
      glUniform4fv(p->Uniform("Color"), 1, glm::value_ptr(color->AsFloat()));
      
      PassVertices(p, GL_TRIANGLES);
    } p->Unbind();
}

void DoubleSlider::Draw() {
  glEnable(GL_BLEND);
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  
  //if (mvMin == NULL || mvMax == NULL) {
    SetHandleModelViews(); //really should just be done once (or when mouse moved)
  //}
  
  if (backgroundColor == NULL) {
    backgroundColor = new Color(ivec4(color->Red(), color->Green(), color->Blue(), 128));
  }
  
  DrawElement(mvBk, backgroundColor); 
  DrawElement(mvMin, color);
  DrawElement(mvMax, color);
}

void DoubleSlider::HandleTouchBegan(ivec2 mouse) {
  
  //printf("HERE in DoubleSlider::HandleTouchBegan\n");
  float y = glm::unProject(vec3(mouse.x, mouse.y, 0.0), modelview, root->projection, root->viewport).y;
  printf("in DoubleSlider::HandleTouchBegan, y = %f\n", y);
  
  float halfH = handleH/2.0;
  
  
  if (maxVal - minVal == 1.0) {
    float middle = (minVal + maxVal) / 2.0;
    
    if (y < middle) {
      minValSelected = true;
      maxValSelected = false;
      offsetY = y - minVal;
      return;
      
    } else if (y > middle) {
      minValSelected = false;
      maxValSelected = true;
      offsetY = y - maxVal;
      return;
    } 
  }
  
  if (y > 0.0 && y < minVal + halfH) {
    minValSelected = true;
    maxValSelected = false;
    offsetY = y - minVal;
    return;
  } else if (y > maxVal - halfH && y < 1.0) {
    minValSelected = false;
    maxValSelected = true;
    offsetY = y - maxVal;
    return;
  } else {
          
      
  
      minValSelected = true;
      maxValSelected = true;
      // float middle = (minVal + maxVal) / 2.0;
      offsetY = (y - minVal) / (maxVal - minVal);
    
  }
  
  
  /*
  float middle = (minVal + maxVal) / 2.0;
  
  
 // if (y > minVal - halfH && y < minVal + halfH) {
    if (y > minVal - halfH && y < middle) {
    minValSelected = true;
    maxValSelected = false;
    offsetY = y - minVal;
    return;
 // } else if (y > maxVal - halfH && y < maxVal + halfH) {
  } else if (y > middle && y < maxVal + halfH) {
    minValSelected = false;
    maxValSelected = true;
    offsetY = y - maxVal;
    return;
  } else if (y > maxVal + halfH) {
    maxVal = 1.0;
  } else if (y < minVal - halfH) {
    minVal = 0.0;
    
  }
  
    minValSelected = false;
    maxValSelected = false;
    offsetY = 0;
  container->isUpdated = true;
  */
}

void DoubleSlider::HandleTouchMoved(ivec2 prevMouse, ivec2 mouse) {
  
  if (minValSelected && maxValSelected) {
    
    float dist = maxVal - minVal;
    
    float off1 = +((dist) * offsetY);
    float off2 = -((dist) * (1.0 - offsetY));
    
    minVal = glm::unProject(vec3(mouse.x, mouse.y, 0.0), modelview, root->projection, root->viewport).y - off1;
    
    maxVal = glm::unProject(vec3(mouse.x, mouse.y, 0.0), modelview, root->projection, root->viewport).y - off2;
    
    if (minVal < 0.0) {
      minVal = 0.0;
      maxVal = dist;
    }
    
    if (maxVal > 1.0) {
      maxVal = 1.0;
      minVal = 1.0 - dist;
    }
    
    
  } else {
    if (minValSelected) {    
      minVal = glm::unProject(vec3(mouse.x, mouse.y, 0.0), modelview, root->projection, root->viewport).y - offsetY;
    }
    
    else if(maxValSelected) {
      maxVal = glm::unProject(vec3(mouse.x, mouse.y, 0.0), modelview, root->projection, root->viewport).y - offsetY;
    }
    
    if (minVal > maxVal) {
      float tmp = minVal;
      minVal = maxVal;
      maxVal = tmp;
      
      maxValSelected = !maxValSelected; //true;
      minValSelected = !minValSelected; //false;
      
    }    

  }
  
  
  
  if (minVal < 0.0) { minVal = 0.0; }
  if (maxVal > 1.0) { maxVal = 1.0; }
  
   
  container->isUpdated = true;
  
  printf("min/max vals = %f/%f\n", minVal, maxVal);
}


void DoubleSlider::HandleTouchEnded(ivec2 mouse) {
  //printf("in DoubleSlider::HandleTouchEnded\n");
  minValSelected = false;
  maxValSelected = false;
}








