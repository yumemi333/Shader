﻿using UnityEngine;

[ExecuteInEditMode]
public class Scene69RenderImage : MonoBehaviour
{
    #region Variables
    public Shader curShader;
    public Color tintColor = Color.white;
    private Material screenMat;
    #endregion

    #region
    Material ScreenMat
    {
        get
        {
            if (screenMat == null)
            {
                screenMat = new Material(curShader);
                screenMat.hideFlags = HideFlags.HideAndDontSave;
            }

            return screenMat;
        }
    }
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
 
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    private void OnDisable()
    {
        if (screenMat)
        {
            DestroyImmediate(screenMat);
        }
    }
}
