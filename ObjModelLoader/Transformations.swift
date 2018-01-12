//
//  Transformations.swift
//  ObjModelLoader
//
//  Created by etu on 10/01/2018.
//  Copyright © 2018 BurtK. All rights reserved.
//

import UIKit
import GLKit
/*pour eviter les accidents de confusion entre les gesture */
enum TransformationState : Int {
    case s_NEW
    case s_SCALE
    case s_TRANSLATION
    case s_ROTATION
}





/*
 _depth is a variable specific to Transformations which will determine the depth of your object in the scene.
 You assign the variable z to _depth in your initializer, and nowhere else.
 You position your model-view matrix at the (x,y) center of your view with the values (0.0, 0.0) and with a z-value of -_depth. You do this because, in OpenGL ES, the negative z-axis runs into the screen.
 
 
 
*/
class Transformations: NSObject {
    let _depth:Float
    var  _scaleStart :Float
    var  _scaleEnd :Float
    var _translationStart = GLKVector2()
    var _translationEnd = GLKVector2()
    //Rotation
    var _rotationStart = GLKVector3()
    //quaternions will represent a rotation around an axis.
    var _rotationEnd = GLKQuaternion()
    var _front = GLKVector3()
    var _right = GLKVector3()
    var _up = GLKVector3()
    var state :TransformationState?
    
init(z: Float, scale s: Float, translation t: GLKVector2, rotation r: GLKVector3)
{
    
 _depth = z
_scaleEnd = s
_scaleStart = _scaleEnd
_translationEnd = t;
    
/*
    
     You create a quaternion that represents a rotation around an axis by using GLKQuaternionMakeWithAngleAndVector3Axis().
     You multiply the resulting quaternion against a master quaternion using GLKQuaternionMultiply().
     All calculations are performed with radians, hence the call to GLKMathDegreesToRadians(). With quaternions, a positive angle performs a counterclockwise rotation, so you send in the negative value of your angle: -r.z.
     
     */
    _front = GLKVector3Make(0.0, 0.0, 1.0)
    var Rrz: Float = GLKMathDegreesToRadians(r.z)
    _rotationEnd = GLKQuaternionIdentity
    _rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-Rrz, _front), _rotationEnd)
    
_right = GLKVector3Make(1.0, 0.0, 0.0)
_up = GLKVector3Make(0.0, 1.0, 0.0)
    
    var a = GLKMathDegreesToRadians(r.x)
    var b = GLKMathDegreesToRadians(r.y)
    _rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-a, _right), _rotationEnd)
    _rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-b, _up), _rotationEnd)
}
    

func start() {
    /* pour ne  pas recommencé à caque fois et concervé le dernier zoom fait*/
    _scaleStart = _scaleEnd
    _translationStart = GLKVector2Make(0.0,0.0)
    _rotationStart = GLKVector3Make(0.0, 0.0, 0.0)
   // S_NEW is a value that will be active whenever the user performs a new gesture.
    state = TransformationState.s_NEW
}

func scale(s: Float) {
    state = TransformationState.s_SCALE
    _scaleEnd = s * _scaleStart
}

func translate(t: GLKVector2, withMultiplier m: Float) {
    state = TransformationState.s_TRANSLATION
    /*
     
     Let’s see what’s happening here:
     m is a multiplier that helps convert screen coordinates into OpenGL ES coordinates. It is defined when you call the function from MainViewController.m.
     dx and dy represent the rate of change of the current translation in x and y, relative to the latest position of _translationEnd. In screen coordinates, the y-axis is positive in the downwards direction and negative in the upwards direction. In OpenGL ES, the opposite is true. Therefore, you subtract the rate of change in y from _translationEnd.y.
     Finally, you update _translationEnd and _translationStart to reflect the new end and start positions, respectively.
     */
    //pour réactiver la translation enlevé le var
   var t =  GLKVector2MultiplyScalar(t, m)
    // 2
    var dx: Float = _translationEnd.x + (t.x - _translationStart.x)
    var dy: Float = _translationEnd.y - (t.y - _translationStart.y)
    
    // 3
    _translationEnd = GLKVector2Make(dx, dy)
    _translationStart = GLKVector2Make(t.x, t.y)
    
}

func rotate(r: GLKVector3, withMultiplier m: Float) {
    state = TransformationState.s_ROTATION
    /*
     dz represents the rate of change of the current rotation about the z-axis
     */
    var dz: Float = r.z - _rotationStart.z
    var  dx: Float = r.x - _rotationStart.x
    var dy: Float = r.y - _rotationStart.y

    
    /*
     Then you simply update _rotationStart and _rotationEnd to reflect the new start and end positions, respectively.
     There is no need to convert r.z to radians this time, since the rotation gesture’s values are already in radians. r.x and r.y will be passed along as 0.0, so you don’t need to worry about them too much—for now.
     */
    _rotationStart = GLKVector3Make(r.x, r.y, r.z)
    _rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-dz, _front), _rotationEnd)
    _rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(dx * m, _up), _rotationEnd)
    _rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(dy * m,_right), _rotationEnd)
}

func getModelViewMatrix() -> GLKMatrix4 {
var modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity
 var quaternionMatrix: GLKMatrix4 = GLKMatrix4MakeWithQuaternion(_rotationEnd)
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, _depth)
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _scaleEnd, _scaleEnd, _scaleEnd)
    //pour réactiver la translation décomenté ça
modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, _translationEnd.x, _translationEnd.y, -_depth);
    
    
    /*
     These two lines perform the last two steps of the quaternion rotation described earlier:
     You derive the 4×4 matrix that performs an (x,y,z) rotation based on a quaternion, using GLKMatrix4MakeWithQuaternion().
     You calculate the product of the resulting matrix with the main model-view matrix using GLKMatrix4Multiply().
     */
   
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, quaternionMatrix)
    return modelViewMatrix
}
    
}
