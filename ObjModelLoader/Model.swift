import GLKit


class Model {
    var shader: BaseEffect!
    var name: String!
    var vertices: [Vertex]!
    var vertexCount: GLuint!
    var indices: [GLuint]!
    var indexCount: GLuint!
    
    var vao: GLuint = 0
    var vaoC: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    var texture: GLuint = 0
    
    var vertexBufferC: GLuint = 0
    var indexBufferC: GLuint = 0
    var textureC: GLuint = 0
    
    
    // ModelView Transformation
    var position : GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0))
    var rotationX : Float = 0.0
    var rotationY : Float = 0.0
    var rotationZ : Float = 0.0
    var scale : Float = 1.0
    
    init(name: String, shader: BaseEffect, vertices: [Vertex], indices: [GLuint]) {
        self.name = name
        self.shader = shader
        self.updateBuffers(vertices: vertices, indices: indices)
    
    }
    
    func updateBuffers(vertices: [Vertex], indices: [GLuint]) {
        if(self.name=="key"){
        self.vertices = vertices
        self.vertexCount = GLuint(vertices.count)
        self.indices = indices
        self.indexCount = GLuint(indices.count)
        
        glGenVertexArraysOES(1, &vao)
        // Créer un VertexArrayObject sur le GPU pour copier tout les sommets et indices du CPU vers le GPU
        glBindVertexArrayOES(vao)
        
        
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size =  MemoryLayout<Vertex>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), count * size, vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(GLsizei(1), &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLuint>.size, indices, GLenum(GL_STATIC_DRAW))
        
        
        
        }
        if(self.name=="cube")
        {
            self.vertices = vertices
            self.vertexCount = GLuint(vertices.count)
            self.indices = indices
            self.indexCount = GLuint(indices.count)
            
            glGenVertexArraysOES(1, &vaoC)
            // Créer un VertexArrayObject sur le GPU pour copier tout les sommets et indices du CPU vers le GPU
            glBindVertexArrayOES(vaoC)
            
            
            glGenBuffers(GLsizei(1), &vertexBufferC)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferC)
            let count = vertices.count
            let size =  MemoryLayout<Vertex>.size
            glBufferData(GLenum(GL_ARRAY_BUFFER), count * size, vertices, GLenum(GL_STATIC_DRAW))
            
            glGenBuffers(GLsizei(1), &indexBufferC)
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBufferC)
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLuint>.size, indices, GLenum(GL_STATIC_DRAW))
            
            
           
            
            
        }
        
        
        // 현재 vao가 바인딩 되어 있어서 아래 함수를 실행하면 정점과 인덱스 데이터가 모두 vao에 저장된다.
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        glVertexAttribPointer(
            VertexAttributes.position.rawValue,
            3,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(
            VertexAttributes.color.rawValue,
            4,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a :: offset is 3*sizeof(GLfloat)
        
        
        glEnableVertexAttribArray(VertexAttributes.texCoord.rawValue)
        glVertexAttribPointer(
            VertexAttributes.texCoord.rawValue,
            2,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET((3+4) * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a | u, v :: offset is (3+4)*sizeof(GLfloat)
        
        glEnableVertexAttribArray(VertexAttributes.normal.rawValue)
        glVertexAttribPointer(
            VertexAttributes.normal.rawValue,
            3,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET((3+4+2) * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a | u, v | nx, ny, nz :: offset is (3+4+2)*sizeof(GLfloat)
        
        
        // 바인딩을 끈다
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        
        
        
        
        
        // Maintenant que vao est lié, la fonction suivante va stocker à la fois les données de vertex et d'index dans vao.
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        glVertexAttribPointer(
            VertexAttributes.position.rawValue,
            3,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(
            VertexAttributes.color.rawValue,
            4,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a :: offset is 3*sizeof(GLfloat)
        
        
        glEnableVertexAttribArray(VertexAttributes.texCoord.rawValue)
        glVertexAttribPointer(
            VertexAttributes.texCoord.rawValue,
            2,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET((3+4) * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a | u, v :: offset is (3+4)*sizeof(GLfloat)
        
        glEnableVertexAttribArray(VertexAttributes.normal.rawValue)
        glVertexAttribPointer(
            VertexAttributes.normal.rawValue,
            3,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET((3+4+2) * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a | u, v | nx, ny, nz :: offset is (3+4+2)*sizeof(GLfloat)
        
        
        // 바인딩을 끈다
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
    }
   
//le cumule des transformations à la matrice de l'identité
    func modelMatrix() -> GLKMatrix4 {
        var modelMatrix : GLKMatrix4 = GLKMatrix4Identity
        modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationX, 1, 0, 0)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationZ, 0, 0, 1)
        modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, self.scale)
        // cumuler la transformation mise à jour dans la class transformation
        modelMatrix = transformations!.getModelViewMatrix()
        return modelMatrix
    }
    
    func render(withParentModelViewMatrix parentModelViewMatrix: GLKMatrix4) {
        
        let modelViewMatrix : GLKMatrix4 = GLKMatrix4Multiply(parentModelViewMatrix, modelMatrix())
        
        shader.modelViewMatrix = modelViewMatrix
        shader.texture = self.texture
        shader.prepareToDraw()
        
        glBindVertexArrayOES(vaoC)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
        glBindVertexArrayOES(0)
        
       // shader.texture = self.texture
        //shader.prepareToDraw()
       glBindVertexArrayOES(vao)
       glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
       glBindVertexArrayOES(0)
        
    }
    
    func updateWithDelta(_ dt: TimeInterval) {
        
    }
    
    func loadTexture(_ filename: String) {
        
        let path = Bundle.main.path(forResource: filename, ofType: nil)!
        let option = [ GLKTextureLoaderOriginBottomLeft: true]
        do {
            let info = try GLKTextureLoader.texture(withContentsOfFile: path, options: option as [String : NSNumber]?)
            self.texture = info.name
        } catch {
            
        }
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}
