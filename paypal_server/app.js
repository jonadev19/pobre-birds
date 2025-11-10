// Carga las variables de entorno desde el archivo .env
// ¡IMPORTANTE! Este debe ser el primer require en tu archivo.
require("dotenv").config();

const express = require("express");
const paypal = require("@paypal/checkout-server-sdk"); // SDK oficial de PayPal
const app = express();

// Middleware para parsear el cuerpo de las solicitudes JSON
app.use(express.json());

// ==========================================================
// Configuración de PayPal
// ==========================================================
// Define el entorno de PayPal (Sandbox para pruebas, Live para producción)
// Utiliza las variables de entorno para almacenar el Client ID y el Client Secret de forma segura.
const environment = new paypal.core.SandboxEnvironment(
  process.env.PAYPAL_CLIENT_ID,
  process.env.PAYPAL_CLIENT_SECRET
);

// Crea una instancia del cliente HTTP de PayPal
const client = new paypal.core.PayPalHttpClient(environment);

// ==========================================================
// Rutas de la API para pagos con PayPal
// ==========================================================

/**
 * @route POST /create-paypal-order
 * @description Crea una nueva orden de pago en PayPal.
 * Requiere el monto a pagar en el cuerpo de la solicitud.
 */
app.post("/create-paypal-order", async (req, res) => {
  const { amount } = req.body; // Recibe el monto desde la aplicación Flutter

  // Valida que el monto sea un número válido
  if (!amount || isNaN(parseFloat(amount))) {
    return res
      .status(400)
      .json({ error: "El monto es requerido y debe ser un número válido." });
  }

  // Crea una solicitud de orden de PayPal
  const request = new paypal.orders.OrdersCreateRequest();
  request.prefer("return=representation"); // Prefiere una respuesta detallada

  // Define el cuerpo de la solicitud para crear la orden
  request.requestBody({
    intent: "CAPTURE", // Indica que el pago será capturado inmediatamente
    purchase_units: [
      {
        amount: {
          currency_code: "USD", // Código de moneda (ej. "USD", "EUR", "MXN")
          value: parseFloat(amount).toFixed(2), // Asegura que el monto tenga 2 decimales
        },
      },
    ],
    application_context: {
      brand_name: "Tu Tienda Flutter", // Nombre de tu marca o aplicación
      shipping_preference: "NO_SHIPPING", // Opciones: NO_SHIPPING, GET_FROM_FILE, SET_PROVIDED_ADDRESS
      user_action: "PAY_NOW", // Muestra el botón "Pagar Ahora" en PayPal
      // Estas URLs son a las que PayPal redirigirá después de la interacción del usuario.
      // Deben ser accesibles desde el exterior si vas a desplegar tu app.
      // Para desarrollo local, puedes usar ngrok o URLs ficticias que tu WebView pueda interceptar.
      return_url: "https://tuapp.com/success", // URL de éxito (tu app/backend detectará esta URL)
      cancel_url: "https://tuapp.com/cancel", // URL de cancelación (tu app/backend detectará esta URL)
    },
  });

  try {
    // Ejecuta la solicitud para crear la orden en PayPal
    const order = await client.execute(request);
    // Devuelve el ID de la orden a la aplicación Flutter
    res.status(200).json({ orderID: order.result.id });
  } catch (error) {
    console.error(
      "Error al crear la orden de PayPal:",
      error.message,
      error.statusCode,
      error.headers
    );
    res
      .status(500)
      .json({
        error: "Error interno del servidor al crear la orden de PayPal.",
      });
  }
});

/**
 * @route POST /capture-paypal-order/:orderID
 * @description Captura un pago autorizado de PayPal usando el ID de la orden.
 * El orderID se recibe como parámetro en la URL.
 */
app.post("/capture-paypal-order/:orderID", async (req, res) => {
  const { orderID } = req.params; // Obtiene el ID de la orden desde los parámetros de la URL

  // Crea una solicitud para capturar la orden
  const request = new paypal.orders.OrdersCaptureRequest(orderID);
  request.prefer("return=representation"); // Prefiere una respuesta detallada

  try {
    // Ejecuta la solicitud para capturar el pago en PayPal
    const capture = await client.execute(request);
    // Devuelve un mensaje de éxito y el ID de la captura a la aplicación Flutter
    res.status(200).json({
      success: true,
      captureID: capture.result.id,
      status: capture.result.status,
      // Puedes incluir más detalles de la captura si los necesitas en el frontend
      // fullResponse: capture.result // Para depuración, no en producción
    });
  } catch (error) {
    console.error(
      "Error al capturar el pago de PayPal:",
      error.message,
      error.statusCode,
      error.headers
    );
    res
      .status(500)
      .json({
        error: "Error interno del servidor al capturar el pago de PayPal.",
      });
  }
});

// ==========================================================
// Inicio del Servidor
// ==========================================================
const PORT = process.env.PORT || 3000; // Usa el puerto definido en .env o el 3000 por defecto
app.listen(PORT, () => {
  console.log(`Backend de PayPal escuchando en el puerto ${PORT}`);
  console.log(`Accede a http://localhost:${PORT}`);
});
