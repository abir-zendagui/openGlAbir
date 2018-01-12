import UIKit //pour utiliser les  composant GUI (Graphical User Interface )
import GLKit //les bases du programmation GPU: matrice , shader, trasformation ...
import SpriteKit

var transformations: Transformations?

class GLKUpdater : NSObject, GLKViewControllerDelegate
{
//NSObject :pour l'utilisation des arrays/strings/dictionaries( alloc , init,copy)
//GLKViewControllerDelegate :affiche une nouvelle frame d'animation
    
    weak var glkViewController : ViewController!
// déclaration de controleur de notre fenetre
    init(glkViewController : ViewController) {
//initialisation de notre controleur par les parametre de viewcontroleur définis en dessous
        self.glkViewController = glkViewController
    }
 
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        //fonction appelé dans chaque frame , résponsable de MAJ utilisé pour l'animation et définis dans ObjModel.swift
        
        
        
        self.glkViewController.model.updateWithDelta(self.glkViewController.timeSinceLastUpdate)
        self.glkViewController.model_r.updateWithDelta(self.glkViewController.timeSinceLastUpdate)
    }
    
    
    
}


class ViewController: GLKViewController {
    
//GLKViewController class provides a rendering loop for smooth animation of OpenGL ES content in a GLKit view
    var glkView: GLKView! // fenetre , a comme parametrele width, height ...class par défaut
    var glkUpdater: GLKUpdater!// pour utiliser les methode déja définis :glkViewController,glkViewControllerUpdate
    var shader : BaseEffect! // une classe pour la configuration des paraemtre de shader
    var model : Model! // création des buffer en CPU et les copié vers GPU
    var model_r: Model!
    override func viewDidLoad() {//quand le programe est chargé
        super.viewDidLoad()
         //x = -5.0
         //y = -5.0
//transformations = Transformations(z: 5.0, scale: 2.0, translation: GLKVector2Make(0.0, 0.0),rotation:GLKVector3Make(0.0, 0.0, 0.0))
transformations = Transformations(z: 5.0, scale: 2.0, translation: GLKVector2Make(0.0, 0.0), rotation: GLKVector3Make(0.0, 0.0, 90.0))
        
        ImageView.isUserInteractionEnabled = true
        
       
        setupGLcontext()
        setupGLupdater()
        setupScene()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Pan (1 Finger)
        /*if(numberOfTouches == 1)
        {
            NSLog("Pan (1 Finger)");
        }
            
            // Pan (2 Fingers)
        else if(numberOfTouches == 2)
        {
            NSLog("Pan (2 Fingers)");
        }
        */
    }
    
@IBOutlet var ImageView: GLKView!
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
//The GLKView class manages OpenGL ES infrastructure to provide a place for your drawing code
        glClearColor(0.0, 0.2, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
 //définir la position de camera
        let viewMatrix : GLKMatrix4 =  GLKMatrix4Rotate(GLKMatrix4MakeTranslation(0, 0, -5),//A matrix.
            GLKMathDegreesToRadians(20),//The angle of the rotation (a positive angle is counterclockwise).
                                            1,//The x component of the rotation vector.
                                            0,
                                            0)
        let viewMatrix2  : GLKMatrix4 = GLKMatrix4Identity;
        self.model.render(withParentModelViewMatrix: viewMatrix)
        self.model_r.render(withParentModelViewMatrix: viewMatrix)
    }
    
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        
       
        if((sender.numberOfTouches == 1) && (transformations?.state == TransformationState.s_NEW) || (transformations?.state == TransformationState.s_TRANSLATION) )
        {
            
            let translation: CGPoint = sender.translation(in: sender.view)
            var x: Float = Float(translation.x / sender.view!.frame.size.width)
            var y: Float = Float(translation.y / sender.view!.frame.size.height)
            print(String(format: "Translation ", x, y))
            NSLog("Pan (1 Finger)");
         transformations?.translate(t: GLKVector2Make( x , y), withMultiplier: 5.0)
            
        }
            
            // Pan (2 Fingers)
        else if((sender.numberOfTouches == 2) && (transformations?.state == TransformationState.s_NEW) || (transformations?.state == TransformationState.s_ROTATION))
        {
            NSLog("Pan (2 Fingers)");
            //The value of m dictates that for every touch-point moved in the x- and/or y-direction, your model rotates 0.5 degrees.
            let m: Float = GLKMathDegreesToRadians(0.5)
            var rotation: CGPoint = sender.translation(in: sender.view)
            transformations?.rotate(r: GLKVector3Make(Float(rotation.x), Float(rotation.y), 0.0), withMultiplier: m)
        }
        
       
       /* CGPoint translation = [sender translationInView:sender.view];
        Float x = translation.x/sender.view.frame.size.width;
        Float y = translation.y/sender.view.frame.size.height;
        NSLog("Translation %.1f %.1f", x, y);*/
    }
    
    
    @IBAction func Reset(_ sender: Any) {
        transformations = Transformations(z: 5.0, scale: 2.0, translation: GLKVector2Make(0.0, 0.0), rotation: GLKVector3Make(0.0, 0.0, 90.0))
        
    }
    
    @IBAction func light(_ sender: Any) {
        
        
    }
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        if((transformations?.state == TransformationState.s_NEW) || (transformations?.state == TransformationState.s_SCALE))
        {
        let scale: Float = Float(sender.scale)
        
        transformations?.scale(s: scale)
        print("Scale ", scale)
        }
    }
    
    
    @IBAction func rotation(_ sender: UIRotationGestureRecognizer) {
        //let rotation: Float = GLKMathRadiansToDegrees(Float(sender.rotation))
        var rotation: Float = Float(sender.rotation)
        transformations?.rotate(r: GLKVector3Make(0.0, 0.0, rotation), withMultiplier: 1.0)
        
        print("Rotation ", rotation)
       
    }
    
   
    
  
}



extension ViewController {
    
    func setupGLcontext() {
        glkView = self.view as! GLKView
        glkView.context = EAGLContext(api: .openGLES2)!
        glkView.drawableDepthFormat = .format16         // for depth testing
        EAGLContext.setCurrent(glkView.context)
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    func setupScene() {
        
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
        self.shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0),GLfloat(self.view.bounds.size.width / self.view.bounds.size.height),1,150)

        // load obj file named "key.obj"
        let fixtureHelper = FixtureHelper()
        let source = try? fixtureHelper.loadObjFixture(name: "cube")
       
        
        
        if let source = source {
                            let loader = ObjLoader(source: source, basePath: fixtureHelper.resourcePath)
                            do {
                                let shapes = try loader.read()
                                self.model = ObjModel(name: "cube", shape: shapes.first!, shader: self.shader)
                                
                                self.model.scale = 0.3
                                }
                            catch
                                {
                                print("Parsing failed with unknown error")
                                }
                        }
        else {
                            print("obj not found")
              }
        
       let source_r = try? fixtureHelper.loadObjFixture(name: "key")
       if let source_r = source_r {
            let loader = ObjLoader(source: source_r, basePath: fixtureHelper.resourcePath)
            do {
                let shapes_r = try loader.read()
                self.model_r = ObjModel(name: "key", shape: shapes_r.first!, shader: self.shader)
                self.model_r.scale = 0.3
            }
            catch
            {
                print("Parsing failed with unknown error")
            }
        }
        else {
            print("obj not found")
        }
       
        
    }
    
override func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?)
{
    super.touchesBegan(touches, with: event)
    
    let touch: UITouch = touches.first as! UITouch
    
    transformations?.start()
    
    if (touch.view == ImageView){
        print("touchesBegan | This is an ImageView")
       // transformations?.translate(t: GLKVector2Make( x : 0.0, y: 0.0), withMultiplier: 5.0)
    }else{
        print("touchesBegan | This is not an ImageView")
    }
}
    
    
     func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first as! UITouch
        
        if (touch.view == ImageView){
            print("touchesMoved | This is an ImageView")
        }else{
            print("touchesMoved | This is not an ImageView")
        }
        
    }
    
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first as! UITouch
        
        if (touch.view == ImageView){
            print("touchesEnded | This is an ImageView")
        }else{
            print("touchesEnded | This is not an ImageView")
        }
        
    }
}



