#include "RectBlobDetect.h"
#include "Camera.hpp"
#include "Renderer.hpp"
#include "Utils.hpp"
#include "Noise.hpp"
#include "CameraManager.h"


#define PIXEL_SKIP 15
#define IS_CAMERA 0
#define USE_RGB_THRESHOLDS 0



RectBlobDetect::RectBlobDetect() {
  
  
  minRed = 0;
  maxRed = 100;
  minGreen = 125;
  maxGreen = 255;
  minBlue = 0;
  maxBlue = 100;
  minLuma = 200;
  maxLuma = 255;
  
  minDensity = 0.5;
  //these will be dependent on the camera resolution! (lower vals for smaller resolution)
  minBlobSize = 64;
  maxBlobWidth = 50;
  maxBlobHeight = 50;
  
  
  useTexCoords = true;
  
  ResourceHandler* rh = ResourceHandler::GetResourceHandler();
  
  //videoTexture = rh->CreateTextureFromImageFile("blobTest1.png");
  
  //videoTexture = rh->CreateVideoTexture("AlloPano5Mbps.mov",  false, false, true);
  videoTexture = rh->CreateVideoTexture("testvid.m4v", false, false, true);
  
  //videoTexture = rh->CreateVideoCaptureTexture(); //pass in resolution, also camera (front or back)!
  videoTexture->SetFilterModes(GL_NEAREST,GL_NEAREST);
  
  
  wScale = 1.0/videoTexture->width;
  hScale = 1.0/videoTexture->height;
  
//  printf("texture w/h = %d/%d\n", videoTexture->width, videoTexture->height);
  
  filterTexture = Texture::CreateSolidTexture(ivec4(0,0,0,255),videoTexture->width, videoTexture->height);
  
  int blobDisplayScale = 1; //make sure not bigger this wont make the texture > than max_texture_size
  Texture* t = Texture::CreateSolidTexture(ivec4(0,0,0,255),videoTexture->width * blobDisplayScale, videoTexture->height * blobDisplayScale);
  
  t->SetFilterModes(GL_LINEAR,GL_LINEAR);
  fbo = new FBO(t);
  
  blobRect = new Rectangle();
  blobRect->useTexCoords = false;
  blobRect->Transform();
  
  blobCircle = new Circle();
  blobCircle->useTexCoords = false;
  blobCircle->Transform();
}


bool RectBlobDetect::CheckIfLegalBlob(Blob* b) {
  
  /*
  printf("num pixels = %d\n", b->numPixels);
  printf("tot pixels = %d\n", b->CalculateSize());
  printf("%d/%d/%d/%d\n", b->left, b->right, b->bottom, b->top);
  
  
  printf("Density = %f\n", b->CalculateDensity(PIXEL_SKIP));
  printf("Size = %d\n", b->CalculateSize()); 
  */
   
  if (b->CalculateSize() < minBlobSize) {
    return false;
  }
  
  if (b->CalculateDensity(PIXEL_SKIP) < minDensity) {
    return false;
  }
  
  return true;
  
}


mat4 RectBlobDetect::CalculateRectMV(Blob* b) {
  mat4 blobGeomMV = mat4::Identity();
  blobGeomMV = mat4::Translate(blobGeomMV, b->left * wScale, b->bottom * hScale, 0.0);
  blobGeomMV = mat4::Scale(blobGeomMV, (b->right - b->left + 1) * wScale, (b->top - b->bottom + 1) * hScale, 1.0);
  
  return blobGeomMV;
}

mat4 RectBlobDetect::CalculateCircleMV(Blob* b) {
  
  mat4 blobGeomMV = mat4::Identity();
  float circleDim = min((b->right - b->left + 1) * wScale , (b->top - b->bottom + 1) * hScale);
  
  // blobGeomMV = mat4::Translate(blobGeomMV, 0.5, 0.5, 0.0);
  
  blobGeomMV = mat4::Translate(blobGeomMV, ( (b->left + b->right + 1) / 2) * wScale, ((b->bottom + b->top + 1) / 2) * hScale, 0.0);
  
  if (IS_CAMERA) {
    blobGeomMV = mat4::Scale(blobGeomMV,  circleDim * 0.5 * root->aspect, circleDim * 0.5, 1.0);
  } else {
    blobGeomMV = mat4::Scale(blobGeomMV,  circleDim * 0.5 , circleDim * 0.5 * root->aspect, 1.0);
  }
  
  return blobGeomMV;
}


bool IS_BUSY = false;

void RectBlobDetect::Draw() {
  
  Program* program;
  ResourceHandler* rh = ResourceHandler::GetResourceHandler();
  
  
  rh->NextVideoFrameLock();
   float averageLuma = AverageLuma(videoTexture, PIXEL_SKIP);
    printf("? averageLuma = %f\n", averageLuma);
  
  //  printf("in Draw : drawing...\n");
  
  
  BlobDetect(videoTexture);
  
//  printf("out Draw : released...\n");
  
  Geom* blobGeom = blobCircle;
  Geom* blobGeom2 = blobRect;
  
  
  
  program = GetProgram("FlatShader");
  
  float BLOB_ASPECT = root->aspect;
  //   if (IS_CAMERA) {
  BLOB_ASPECT = (float)root->viewport.w/(float)root->viewport.z;
  
  //   }
  
  
  
  Blob* topBlob = NULL;
  int cb;
  list<Blob*>::iterator it = blobs.begin();
  
  for(cb = 0, it = blobs.begin(); it != blobs.end(); ++it, ++cb){
    if ( cb == 0 ) {
      topBlob = (*it);
      continue;
    }
    if ( CheckIfLegalBlob( (*it) ) == false) {
      continue;
    }
    
    if ((*it)->CalculateSize() > topBlob->CalculateSize() ) {
      topBlob = (*it);
    }
  }
  
  
    fbo->Bind(); {
      glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 
      
      if (topBlob != NULL) {
        
      program->Bind(); {
        
        /*
         list<Blob*>::iterator it;
         for(it = blobs.begin(); it != blobs.end(); ++it){
         if ( CheckIfLegalBlob( (*it) ) == false) {
         continue;
         }
         */
        
        mat4 blobGeomMV = CalculateCircleMV(topBlob);
        
        
        glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, mat4::Identity().Pointer());
        glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, blobGeomMV.Pointer());
        glUniformMatrix4fv(program->Uniform("Projection"), 1, 0, root->projection.Pointer());
        glUniform4fv(program->Uniform("Color"), 1, vec4(0,0,1,1).Pointer());
        blobGeom->PassVertices(program, GL_TRIANGLES);
        
        
        blobGeomMV = CalculateRectMV(topBlob);
        
        
        glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, mat4::Identity().Pointer());
        glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, blobGeomMV.Pointer());
        glUniformMatrix4fv(program->Uniform("Projection"), 1, 0, root->projection.Pointer());
        glUniform4fv(program->Uniform("Color"), 1, vec4(0,1,0,1).Pointer());
        blobGeom2->PassVertices(program, GL_LINES);
        }
      }program->Unbind();
    } fbo->Unbind();
    
    
  
  
  
  Renderer::GetRenderer()->BindDefaultFrameBuffer();
  ivec4 vp = root->viewport;
  glViewport(vp.x, vp.y, vp.z, vp.w);
  
  //needs to be done to handle weird camera orientation! (only works when camera locked right now... revisit)
  ROT_MV = modelview; 
  
  if (IS_CAMERA) {
    ROT_MV = mat4::Translate(ROT_MV, 0.5, 0.5, 0.0);
    
    ROT_MV = mat4::RotateY(ROT_MV, 180);
    ROT_MV = mat4::RotateZ(ROT_MV, 90);
    ROT_MV = mat4::Translate(ROT_MV, -0.5, -0.5, 0.0);
  }
  
  glEnable(GL_BLEND);
  glBlendFunc( GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR );
  
  program = GetProgram("SingleTexture");
  program->Bind(); {
    
    // glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, modelview.Pointer());
    glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, ROT_MV.Pointer());
    glUniformMatrix4fv(program->Uniform("Projection"), 1, 0, root->projection.Pointer());
    
    videoTexture->Bind(GL_TEXTURE0); {
      glUniform1i(program->Uniform("s_tex"), 0);
      PassVertices(program, GL_TRIANGLES);
    } videoTexture->Unbind(GL_TEXTURE0);
    
    
    filterTexture->Bind(GL_TEXTURE0); {
      glUniform1i(program->Uniform("s_tex"), 0);
      PassVertices(program, GL_TRIANGLES);
    } filterTexture->Unbind(GL_TEXTURE0);
    
    fbo->texture->Bind(GL_TEXTURE0); {
      glUniform1i(program->Uniform("s_tex"), 0);
      PassVertices(program, GL_TRIANGLES);
    } fbo->texture->Unbind(GL_TEXTURE0);
       
  } program->Unbind();
  
  rh->NextVideoFrameUnlock();
}


Blob* RectBlobDetect::MergeBlobs() { //vector<Blob*> blobs) {
  
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
    
    left = min((*it)->left, left);
    right = max((*it)->right, right);
    bottom = min((*it)->bottom, bottom);
    top = max((*it)->top, top);
    numPixels += (*it)->numPixels;
  }
  
  //printf("MERGED blob %d %d %d %d\n", left, right, bottom, top);
  return new Blob(ivec4(left, right, bottom, top), numPixels  );
}



float RectBlobDetect::RgbaToLuma(ivec4 rgba) {
  return ((float)rgba.x * 0.2126) +  ((float)rgba.y * 0.7152) + ((float)rgba.z * 0.0722) ;
}

bool RectBlobDetect::PixelWithinLumaThresholds(ivec4 pixel) {
  
  float luma = RgbaToLuma(pixel);
  
  if (luma >= minLuma && luma < maxLuma) {
    return true;
  }
  
  return false;
}


bool RectBlobDetect::PixelWithinRGBThresholds(ivec4 pixel) {
  
  if (pixel.x >= minRed && pixel.x < maxRed &&
      pixel.y >= minGreen && pixel.y < maxGreen &&
      pixel.z >= minBlue && pixel.z < maxBlue ) {
    return true;
  }
  
  
  return false;
}

void RectBlobDetect::BlobDetect(Texture *t) {
  
  //filterTexture->SetRectAt(0,0,filterTexture->width, filterTexture->height, ivec4(0,0,0,255));
  
  ivec4 pixel;
  blobs.clear();
  
  list<Blob*> newBlobs;
  list<Blob*>::iterator blobIter;
  
  for (int y = 0; y < t->height; y+=PIXEL_SKIP) {
    for (int x = 0; x < t->width; x+=PIXEL_SKIP) {
      
      float goodPixel = false;
      if (USE_RGB_THRESHOLDS == 1) {
        goodPixel = PixelWithinRGBThresholds(t->GetPixelAt(x, y));
      } else {
        goodPixel = PixelWithinLumaThresholds(t->GetPixelAt(x, y));
      }
      
      if (goodPixel == true) {
        newBlobs.clear();
        checkBlobs.clear();
        
        int rectSize = max(1,PIXEL_SKIP/2);
       // filterTexture->SetRectAt(x-rectSize,y-rectSize,rectSize*2,rectSize*2, ivec4(0,255,0,128));
        
        for(blobIter = blobs.begin(); blobIter != blobs.end(); ++blobIter) {
          
          
          if ((*blobIter)->AddPixel(ivec2(x,y)) == true) {
            checkBlobs.push_back((*blobIter));
          }
        }
        
        //new blob?
        if (checkBlobs.size() == 0) {
          fbo->texture->SetPixelAt(x,y,ivec4(0,255,0,255)); 
          //  videoTexture->SetPixelAt(x,y,ivec4(0,255,0,255)); 
          
          //printf("\t new blob at %d %d\n", x, y);
          newBlobs.push_back( new Blob(ivec2(x,y)) );
        }
        
        
        //merge these blobs
        else if (checkBlobs.size() > 1) {
          fbo->texture->SetPixelAt(x,y,ivec4(255,0,0,255)); 
          // videoTexture->SetPixelAt(x,y,ivec4(255,0,0,255)); 
          newBlobs.push_back(MergeBlobs());
        }
        
        
        // list<Blob*>::iterator blobIter2;
        
        // Blob* biggestBlob;
        
        int ccc = 0;
        for(blobIter = blobs.begin(); blobIter != blobs.end(); ++blobIter) {
          
          //printf("BLOB %d\n", ccc++);
          
          if ((*blobIter)->markedForRemoval == false) {
            newBlobs.push_back(*blobIter);
          } else {
            delete *blobIter;
          }
        }
        
        //  printf("new Blobs size = %lu\n", newBlobs.size());
        
        blobs = newBlobs;
      } 
      
    }
  } 
  
}

float RectBlobDetect::AverageLuma(Texture* t, int sampleSkip) {
  
  float luma = 0;
  int sampleTotal = 0;
  
  for (int y = 0; y < t->height; y+=sampleSkip) {
    for (int x = 0; x < t->width; x+=sampleSkip) {
      luma += RgbaToLuma(t->GetPixelAt(x,y)); 
      sampleTotal++;
    }
  }
  
  return ((float)luma / (float)(sampleTotal))/255.0;
}

void RectBlobDetect::HandleTouchBegan(ivec2 mouse) {
  mouse.Print("in RectBlobDetect::HandleTouchBegan, mouse pt = ");
 
  vec3 objPt = mat4::Unproject(mouse.x, mouse.y, 0, ROT_MV, root->projection, root->viewport);
  objPt.Print("RectBlobDetect : mouse in 3D Coords = ");
  
  ivec2 pixelPt = ivec2(objPt.x * videoTexture->width, objPt.y * videoTexture->height);
  pixelPt.Print("Pixel coords = ");
  ivec4 pixel = videoTexture->GetPixelAt(pixelPt.x, videoTexture->height - pixelPt.y);
  pixel.Print("PIXEL is ");
  
  int inc = 5;
  minRed = pixel.x - inc;
  maxRed = pixel.x + inc;
  minGreen = pixel.y - inc;
  maxGreen = pixel.y + inc;
  minBlue = pixel.z - inc;
  maxBlue = pixel.z + inc;
 
  
  float luma = RgbaToLuma(pixel);
  minLuma = luma - inc;
  maxLuma = luma + inc;
  
  printf("min/max rgba:%d/%d %d/%d %d/%d  luma:%d/%d\n", minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue, minLuma, maxLuma);
  
  filterTexture->SetRectAt(pixelPt.x, videoTexture->height - pixelPt.y, 100,100, pixel);
}


void RectBlobDetect::HandleTouchMoved(ivec2 prevMouse, ivec2 mouse) {
  mouse.Print("in RectBlobDetect::HandleTouchMoved, mouse pt = ");
  
  int inc = 5;
  if (mouse.x > prevMouse.x) {
    minRed -= inc;
    maxRed += inc;
    minGreen -= inc;
    maxGreen += inc;
    minBlue -= inc;
    maxBlue += inc;
    minLuma -= inc;
    maxLuma += inc;
  } else {
    minRed += inc;
    maxRed -= inc;
    minGreen += inc;
    maxGreen -= inc;
    minBlue += inc;
    maxBlue -= inc;
    minLuma += inc;
    maxLuma -= inc;
  }
 /* 
  minRed = max(0,minRed);
  maxRed = min(255,maxRed);
  minGreen = max(0,minGreen);
  maxGreen = min(255,maxGreen);
  minBlue = max(0,minBlue);
  maxBlue = min(255,maxBlue);
  
  if (minRed > maxRed) {
    int temp = minRed;
    minRed = maxRed;
    maxRed = temp;
  }
  if (minGreen > maxRed) {
    int temp = minGreen;
    minGreen = maxGreen;
    maxGreen = temp;
  }
  if (minBlue > maxRed) {
    int temp = minBlue;
    minBlue = maxBlue;
    maxBlue = temp;
  }
  */
  printf("min/max rgba:%d/%d %d/%d %d/%d  luma:%d/%d\n", minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue, minLuma, maxLuma);
}



