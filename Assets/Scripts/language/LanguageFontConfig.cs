using System.Collections.Generic;
using Sirenix.OdinInspector;
using UnityEngine;


public class LanguageFontConfig : SerializedMonoBehaviour
{

    [ShowInInspector, TabGroup("Text Font 配置")]
    public Dictionary<string, Font> text_font = new Dictionary<string, Font>();

    [ShowInInspector, TabGroup("Text Mesh Font 配置")]
    public Dictionary<string, Font> text_mesh_font = new Dictionary<string, Font>();
}

