using UnityEngine;

namespace Core.Extensions
{
    public static class Vector2Extensions
    {
        public static Vector3 XZ(this Vector2 v, float y = 0f)
        {
            return new Vector3(v.x, y, v.y);
        }
    }
}