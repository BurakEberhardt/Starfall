using UnityEngine;
using UnityEngine.Serialization;

public class CameraController : MonoBehaviour
{
    [SerializeField] Transform _playerTransform;
    [SerializeField] float _smoothTime = 0.3f;
    [SerializeField] Vector3 _angle;
    [SerializeField] float _distance;
    [SerializeField] Vector3 _offset;
    Vector3 _velocity = Vector3.zero;

    void FixedUpdate()
    {
        var rotation = Quaternion.Euler(_angle.x, 0, 0) * Quaternion.Euler(0f, _angle.y, 0) * Quaternion.Euler(0, 0, _angle.z);
        var targetPosition = _playerTransform.position + rotation * new Vector3(0f, 0f, _distance) + _offset;
        transform.localPosition = Vector3.SmoothDamp(transform.position, targetPosition, ref _velocity, _smoothTime);
        transform.localRotation = rotation;
    }
}