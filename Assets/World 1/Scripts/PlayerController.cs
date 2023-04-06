using Core.Extensions;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [SerializeField] private float speed = 5f;
    private Rigidbody rb;
    private Vector2 movementInput;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    private void OnEnable()
    {
        // Enable the movement action map
        // InputSystem.EnableDevice(UnityEngine.InputSystem.Gamepad.current);
        InputSystem.EnableDevice(UnityEngine.InputSystem.Keyboard.current);
        InputActionMap movementActionMap = new InputActionMap("Movement");
        movementActionMap.AddAction("Move", binding: "<Gamepad>/leftStick, <Keyboard>/arrowKeys");
        movementActionMap.Enable();
        movementActionMap["Move"].performed += OnMovePerformed;
        movementActionMap["Move"].canceled += OnMoveCanceled;
    }

    private void OnDisable()
    {
        // Disable the movement action map
        // InputSystem.DisableDevice(UnityEngine.InputSystem.Gamepad.current);
        InputSystem.DisableDevice(UnityEngine.InputSystem.Keyboard.current);
        InputActionMap movementActionMap = new InputActionMap("Movement");
        movementActionMap["Move"].performed -= OnMovePerformed;
        movementActionMap["Move"].canceled -= OnMoveCanceled;
        movementActionMap.Disable();
    }

    private void OnMovePerformed(InputAction.CallbackContext context)
    {
        movementInput = context.ReadValue<Vector2>().XZ();
    }

    private void OnMoveCanceled(InputAction.CallbackContext context)
    {
        movementInput = Vector2.zero.XZ();
    }

    private void FixedUpdate()
    {
        rb.velocity = movementInput * speed;
    }
}