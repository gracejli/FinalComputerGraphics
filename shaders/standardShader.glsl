
#ifdef VERTEX_SHADER
// ------------------------------------------------------//
// ----------------- VERTEX SHADER ----------------------//
// ------------------------------------------------------//

attribute vec3 a_position; // the position of each vertex
attribute vec3 a_normal;   // the surface normal of each vertex

//TODO DONE: Add a_texcoord attribute
attribute vec2 a_texcoord; //the texture coordinate attribute 

uniform mat4 u_matrixM; // the model matrix of this object
uniform mat4 u_matrixV; // the view matrix of the camera
uniform mat4 u_matrixP; // the projection matrix of the camera

uniform mat3 u_matrixInvTransM; 
varying vec3 v_normal; // normal to forward to the fragment shader

varying vec2 v_texcoord; 

//just added this 
uniform vec3 u_cameraPosition;
varying vec3 v_surfaceToView;

void main() {
    //v_normal = u_matrixInvTransM * a_normal; 

    v_normal = normalize(u_matrixInvTransM * a_normal); // set normal data for fragment shader
    
    vec3 surfaceWorldPositon = (u_matrixM * vec4(a_position, 1)).xyz;

    //TODO DONE: Transfer texCoord attribute value to varying
    v_texcoord = a_texcoord; 

    gl_Position = u_matrixP * u_matrixV * u_matrixM * vec4 (a_position, 1);

    v_surfaceToView = u_cameraPosition - surfaceWorldPositon;
}

#endif

#ifdef FRAGMENT_SHADER
// ------------------------------------------------------//
// ----------------- Fragment SHADER --------------------//
// ------------------------------------------------------//


precision highp float; //float precision settings

uniform vec3 u_tint;            // the tint color of this object

uniform vec3 u_directionalLight;// directional light in world space
uniform vec3 u_directionalColor;// light color
uniform vec3 u_ambientColor;    // intensity of ambient light

uniform float u_shininess; 
uniform float u_specularity; 

varying vec3 v_normal;  // normal from the vertex shader

varying vec3 v_surfaceToView; 

//TODO DONE: Add v_texcoord varying
varying vec2 v_texcoord; 
//TODO: Add u_mainTex sampler (main texture)
uniform sampler2D u_mainTex; 


void main(void){
    //the old original shader without blinn phong
    // calculate basic directional lighting
    vec3 normal = normalize(v_normal);

    vec3 surfaceToLightDirection = -normalize(u_directionalLight);
    vec3 surfaceToViewDirection = normalize(v_surfaceToView);
    vec3 halfVector = normalize(surfaceToLightDirection + surfaceToViewDirection); 

    float diffuseIntensity = max(0.0, dot(normal, -u_directionalLight));
    vec3 diffuseColor = u_directionalColor * diffuseIntensity;
 
    vec3 result = u_ambientColor + diffuseColor;

    result = clamp(result, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));

    float light = dot(normal, surfaceToLightDirection);
    float specular = 0.0;
    if (diffuseIntensity > 0.0) specular = pow(dot(normal, halfVector), u_shininess);

    result *= u_tint.rgb; 
    result += u_specularity * specular;

    //gl_FragColor = vec4(result, 1);
    
    vec3 textureColor = texture2D(u_mainTex, v_texcoord).rgb; 
    vec3 baseColor = textureColor * u_tint;
   
    vec3 finalColor = result * baseColor; // apply lighting to color

    gl_FragColor = vec4(finalColor, 1);
}

#endif
