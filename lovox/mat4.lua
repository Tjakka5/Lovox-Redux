local Ffi = require("ffi")

local Mat4 = {}
Mat4.__index = Mat4

-- Define a struct for our custom vertex format
Ffi.cdef[[
   typedef struct {
      float mat[16];
   } fm_matrix;

   typedef struct {
      float mat[16];
      unsigned char r, g, b, a;
   } fm_instance;
]]

local mat  = Ffi.typeof('fm_matrix')
Mat4.newMatrix = mat

local temp = Mat4.newMatrix()

function Mat4.clear (a)
   local e = a.mat

   e[0],  e[1],  e[2],  e[3]  = 0, 0, 0, 0
   e[4],  e[5],  e[6],  e[7]  = 0, 0, 0, 0
   e[8],  e[9],  e[10], e[11] = 0, 0, 0, 0
   e[12], e[13], e[14], e[15] = 0, 0, 0, 0

   return a
end

function Mat4.setIdentity(a)
   local e = a.mat

   e[0],  e[1],  e[2],  e[3]  = 1, 0, 0, 0
   e[4],  e[5],  e[6],  e[7]  = 0, 1, 0, 0
   e[8],  e[9],  e[10], e[11] = 0, 0, 1, 0
   e[12], e[13], e[14], e[15] = 0, 0, 0, 1

   return a
end

function Mat4.setTranslation(a, x, y, z)
   local e = a:setIdentity().mat

   e[12] = x or 0
   e[13] = y or 0
   e[14] = z or 0

   return a
end

function Mat4.setRotation(a, angle)
   local c, s = math.cos(angle), math.sin(angle)

   local e = a:setIdentity().mat

   e[0] =  c
   e[4] = -s
   e[1] =  s
   e[5] =  c

   return a
end

function Mat4.setScale(a, sx, sy, sz)
   local e = a:setIdentity().mat

   e[0]  = sx or 1
   e[5]  = sy or 1
   e[10] = sz or 1

   return a
end

function Mat4.translate(a, x, y, z)
   temp:setTranslation(x, y, z)
   return a:apply(temp)
end

function Mat4.rotate(a, angle)
   temp.setRotation(angle)
   return a:apply(temp)
end

function Mat4.scale(a, sx, sy, sz)
   temp:setScale(sx, sy, sz)
   return a:apply(temp)
end

function Mat4.apply(m, b)
   local tmp, a, b = temp.mat, a.mat, b.mat

   tmp[1]  = a[1]  * b[1] + a[2]  * b[5] + a[3]  * b[9]  + a[4]  * b[13]
   tmp[2]  = a[1]  * b[2] + a[2]  * b[6] + a[3]  * b[10] + a[4]  * b[14]
   tmp[3]  = a[1]  * b[3] + a[2]  * b[7] + a[3]  * b[11] + a[4]  * b[15]
   tmp[4]  = a[1]  * b[4] + a[2]  * b[8] + a[3]  * b[12] + a[4]  * b[16]
   tmp[5]  = a[5]  * b[1] + a[6]  * b[5] + a[7]  * b[9]  + a[8]  * b[13]
   tmp[6]  = a[5]  * b[2] + a[6]  * b[6] + a[7]  * b[10] + a[8]  * b[14]
   tmp[7]  = a[5]  * b[3] + a[6]  * b[7] + a[7]  * b[11] + a[8]  * b[15]
   tmp[8]  = a[5]  * b[4] + a[6]  * b[8] + a[7]  * b[12] + a[8]  * b[16]
   tmp[9]  = a[9]  * b[1] + a[10] * b[5] + a[11] * b[9]  + a[12] * b[13]
   tmp[10] = a[9]  * b[2] + a[10] * b[6] + a[11] * b[10] + a[12] * b[14]
   tmp[11] = a[9]  * b[3] + a[10] * b[7] + a[11] * b[11] + a[12] * b[15]
   tmp[12] = a[9]  * b[4] + a[10] * b[8] + a[11] * b[12] + a[12] * b[16]
   tmp[13] = a[13] * b[1] + a[14] * b[5] + a[15] * b[9]  + a[16] * b[13]
   tmp[14] = a[13] * b[2] + a[14] * b[6] + a[15] * b[10] + a[16] * b[14]
   tmp[15] = a[13] * b[3] + a[14] * b[7] + a[15] * b[11] + a[16] * b[15]
   tmp[16] = a[13] * b[4] + a[14] * b[8] + a[15] * b[12] + a[16] * b[16]
 
   for i=1, 16 do
     a[i] = tmp[i]
   end
 
   return m
end

do
   local inst = Ffi.typeof('fm_instance')

   Mat4.matrixSize   = Ffi.sizeof(mat )
   Mat4.instanceSize = Ffi.sizeof(inst)

   function Mat4.castInstances(pointer)
      return Ffi.cast('fm_instance*', pointer)
   end

   Ffi.metatype(mat,  Mat4)
   Ffi.metatype(inst, Mat4)
end

return Mat4