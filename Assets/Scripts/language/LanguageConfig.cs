using System.Collections;
using System.Collections.Generic;
using System.IO;
using Sirenix.OdinInspector;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.U2D;
#if UNITY_EDITOR

using Sirenix.OdinInspector.Editor;
using UnityEditor;
using Sirenix.Utilities;
using Sirenix.Utilities.Editor;
#endif
using LuaFramework;

public class LanguageConfig : SerializedMonoBehaviour
{
    public enum Type
    {
        def,        // 默认语言,模块内已包含,不需要其他处理
        download,   // 下载的
        // 下面一项需要注释掉,这里只是说明还有一种类型表示没有该语言包
        // 这里只要在 type_dic 中找不到上面2种类型,则表示没有该语言包
        //no,         // 没有该语言包
    }

    [SerializeField, TabGroup("Text 配置"), ListDrawerSettings(IsReadOnly = true)]
    private Dictionary<string, Text> text_list_dic = new Dictionary<string, Text>();


    [SerializeField, TabGroup("Image 配置"), ListDrawerSettings(IsReadOnly = true)]
    private Dictionary<string, Image> image_list_dic = new Dictionary<string, Image>();


    [SerializeField, TabGroup("TextMesh 配置"), ListDrawerSettings(IsReadOnly = true)]
    private Dictionary<string, TextMesh> text_mesh_font_list = new Dictionary<string, TextMesh>();


    [SerializeField, TabGroup("SpriteRenderer 配置"), ListDrawerSettings(IsReadOnly = true)]
    private Dictionary<string, SpriteRenderer> sprite_renderer_list = new Dictionary<string, SpriteRenderer>();


    [SerializeField, TabGroup("Image 配置")]
    private bool NativeSize = false;

    AssetBundle ab;

    static Dictionary<string, Type> type_dic = new Dictionary<string, Type>();

    static string dir_path;

    static string _language_type = "";
    [HideInInspector]
    public static string language_type
    {
        get
        {
            return _language_type;
        }
    }
    string module_path;

    static public void SetDirPath(string path)
    {
        dir_path = path;
    }

    static public void SetLanguageType(string lan, Type t)
    {
        if (type_dic.ContainsKey(lan) == false)
        {
            type_dic.Add(lan, t);
        }
    }

    static public void SetCurrentLanguage(string lan_type)
    {
        _language_type = lan_type;
    }

    static public bool editorLoad = false;

    public void SetModulePath(string path)
    {
        Type t;
        //Debug.LogError("设置的模块路径 path:" + path);
        // return;
        if(type_dic.TryGetValue(language_type, out t))
        {
            // 是下载的语言包
            if (t == Type.download)
            {
                module_path = path;
                if (editorLoad)
                {

                    // 文字替换
                    TextAsset ass = (TextAsset)ResourceManager.Inst.luaEditorLoadRes($"{module_path}/language/{language_type}/language.json", typeof(TextAsset));
                    if (ass)
                    {
                        var json = LitJson.JsonMapper.ToObject(ass.ToString());
                        UpdateText(json);
                    }
                    else if (text_list_dic.Count > 0)
                        Debug.LogError($"多语言 Text 替换,未找到 language.json <color=#FF0000> language:{language_type} 模块:{module_path} </color>, 或者是对象么有配置");

                    // 图片替换
                    SpriteAtlas atlas = (SpriteAtlas)ResourceManager.Inst.luaEditorLoadRes($"{module_path}/language/{language_type}/" + "atlas.spriteatlas", typeof(SpriteAtlas));
                    if (atlas)
                        UpdateTexture(atlas);
                    else if (image_list_dic.Count > 0)
                        Debug.LogError($"多语言 Sprite 替换,<color=#FF0000>未找到对应的 图集 atlas, module_path:{module_path}/language/{language_type} </color>, 或者是对象么有配置");


                    // 字体替换
                    GameObject obj = (GameObject)ResourceManager.Inst.luaEditorLoadRes($"{module_path}/language/{language_type}/font_config.prefab", typeof(GameObject));
                    if (obj) 
                        UpdateFont(obj.GetComponent<LanguageFontConfig>());
                    // 找不到这个表示不需要替换字体,这里不加日志,因为无法判断没有这个对象是不需要还是漏了

                }
                else
                {
                    ABInfo info = ResourceManager.Inst.LoadBundle($"{module_path}/language/{language_type}");
                    if (info != null)
                        ab = info.m_assetBundle;

                    if (ab == null)
                    {
                        Debug.LogError($"多语言图片替换,  <color=#FF0000> 未找到对应的多语言模块:{module_path}/language/{language_type} </color>");
                        return;
                    }
                    // 文字替换
                    var ass = ab.LoadAsset<TextAsset>("language.json");
                    if (ass)
                    {
                        var json = LitJson.JsonMapper.ToObject(ass.ToString());
                        UpdateText(json);
                    }
                    // 图片替换
                    var atlas = ab.LoadAsset<SpriteAtlas>("atlas");
                    if (atlas)
                        UpdateTexture(atlas);
                    else
                        Debug.LogError($"多语言 Sprite 替换,<color=#FF0000>未找到对应的 图集 atlas, module_path:{module_path}/language/{language_type} </color>, 或者是对象么有配置");

                    // 字体替换
                    GameObject obj = ab.LoadAsset<GameObject>("font_config.prefab");
                    if (obj)
                        UpdateFont(obj.GetComponent<LanguageFontConfig>());
                    // 找不到这个表示不需要替换字体,这里不加日志,因为无法判断没有这个对象是不需要还是漏了
                }
            }
        }
        else
        {
            Debug.LogError($" <color=#FF0000>语言类型:{language_type}, 不在配置范围内,请在统一配置中新增当前可用语言  </color>");
        }
    }

    void UpdateTexture(SpriteAtlas atlas)
    {
        if (atlas)
        {
            foreach (var info in image_list_dic)
            {
                var str_s = info.Key.Split('.');
                var sprite = atlas.GetSprite(str_s[0]);
                if (sprite && info.Value)
                    info.Value.sprite = sprite;
                else
                    Debug.LogError($"多语言 Sprite 替换,未找到对应的图片, <color=#FF0000> module_path:{module_path}/language/{language_type},key = {str_s[0]} </color>, 或者是对象么有配置");
                if (NativeSize)
                    info.Value.SetNativeSize();
            }
            foreach (var info in sprite_renderer_list)
                if (info.Key == "" || info.Value == null)
                    Debug.LogError($"多语言 sprite_renderer 替换,缺少配置 <color=#FF0000>  模块为:{module_path} key:{info.Key} </color>");
                else
                {
                    var str_s = info.Key.Split('.');
                    var spr = atlas.GetSprite(str_s[0]);
                    if (spr)
                        info.Value.sprite = spr;
                    else
                        Debug.LogError($"多语言 sprite_renderer 替换,找不到图片  <color=#FF0000>  language:{language_type}  模块为:{module_path} 图片名为:{info.Key} </color>");

                }
        }
    }

    void UpdateText(LitJson.JsonData json)
    {
        //var ass = ab.LoadAsset<TextAsset>("language.json");
        //var json = LitJson.JsonMapper.ToObject(ass.ToString());
        foreach(var info in text_list_dic)
        {
            if (((IDictionary)json).Contains(info.Key) && info.Value)
                info.Value.text = json[info.Key].ToString();
            else
                Debug.LogError($" Text 替换,未找到  <color=#FF0000>  language:{language_type} module:{module_path} key:{info.Key} </color>, 或者是对象么有配置");
        }

        foreach(var info in text_mesh_font_list)
        {
            if (((IDictionary)json).Contains(info.Key) && info.Value)
                info.Value.text = json[info.Key].ToString();
            else
                Debug.LogError($" TextMesh 替换,未找到  <color=#FF0000>  language:{language_type} module:{module_path} key:{info.Key}  </color>, 或者是对象么有配置");
        }
    }


    void UpdateFont(LanguageFontConfig config)
    {
        if (config == null)
        {
            Debug.LogError($"多语言  <color=#FF0000> 字体替换,没有挂 LanguageFontConfig 脚本 language:{language_type} module:{module_path}  </color>");
            return;
        }
        foreach (var info in config.text_font)
        {
            Text t;
            if (text_list_dic.TryGetValue(info.Key, out t))
                t.font = info.Value;
            else
                Debug.LogError($"多语言  <color=#FF0000> Text 字体替换, text_list_dic中没有找到 key:{info.Key}, language:{language_type} module:{module_path}  </color>");
        }

        foreach (var info in config.text_mesh_font)
        {
            TextMesh t;
            if (text_mesh_font_list.TryGetValue(info.Key, out t))
                t.font = info.Value;
            else
                Debug.LogError($"多语言  <color=#FF0000> TextMesh 字体替换, text_list_dic中没有找到 key:{info.Key}, language:{language_type} module:{module_path}  </color>");
        }
    }


#if UNITY_EDITOR
    [Button("打开窗口", ButtonSizes.Large)]
    private void OpenEditorWindow()
    {
        var window = Editor.CreateInstance<LanguageConfigEditorWindow>();
        window.language_config = this;
        window.Show();
        window.position = GUIHelper.GetEditorWindowRect().AlignCenter(800, 600);
    }
#endif
}
#if UNITY_EDITOR


//定义一个子窗口方便拖放
public class LanguageConfigEditorWindow : UnityEditor.EditorWindow
{
    private PropertyTree defaultPropertyTree;

    public LanguageConfig language_config;

    private void OnEnable()
    {
        this.wantsMouseMove = true;
    }

    private void OnGUI()
    {
        this.DrawWithDefaultLocator();


        this.RepaintIfRequested();
    }

    private void DrawWithDefaultLocator()
    {
        if (this.defaultPropertyTree == null && language_config)
        {
            this.defaultPropertyTree = PropertyTree.Create(language_config);
        }

        SirenixEditorGUI.BeginBox("Default Locator");
        this.defaultPropertyTree?.Draw(false);
        SirenixEditorGUI.EndBox();
    }
}

#endif