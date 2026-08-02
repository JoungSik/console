const SERVICE_WORKER_PATH = "/service-worker.js"
const SERVICE_WORKER_SCOPE = "/"

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register(SERVICE_WORKER_PATH, { scope: SERVICE_WORKER_SCOPE })
      .catch((error) => console.error("ServiceWorker registration failed:", error))
  })
}
