
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;



public class UIAdaptor : MonoBehaviour
{
    static float UIWidth = 1080;
    static float UIHeight = 1920;
    static float uiAspectRatio = UIWidth / UIHeight;

    void Start()
    {
        RectTransform background = gameObject.GetComponent<RectTransform>();

        float screenAspectRatio = (float)Screen.width / Screen.height;

        if (screenAspectRatio < uiAspectRatio)
        {
            background.localScale *= uiAspectRatio / screenAspectRatio;
        }
        if (screenAspectRatio > uiAspectRatio)
        {
            background.localScale *=   screenAspectRatio/ uiAspectRatio;
        }
    }
}
