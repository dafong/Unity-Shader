using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
public class DepthTexture : MonoBehaviour {

    public Material material;

    private void Awake() {
        //在移动设备上需要手动设置该值才会产生深度图纹理 在桌面上不需要
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, material);
    }

}
