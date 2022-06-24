using UnityEngine;
using UnityEngine.SceneManagement;

public class InitializeOnLoad : MonoBehaviour
{

    [RuntimeInitializeOnLoadMethod]
    static void Initialize()
    {
        if (SceneManager.GetActiveScene().name == "miniload")
        {
            return;
        }
        SceneManager.LoadScene("miniload");
    }

}
