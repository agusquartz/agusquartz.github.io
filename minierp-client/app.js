// ============ Config ============
const BASE_URL = (new URLSearchParams(location.search).get("api")) || "http://185.218.124.154:8800";
const ENDPOINTS = {
  login: "/api/users/users/login/",
  profile: "/api/users/users/profile/",
  products: "/api/inventory/products/"
};

const $status = document.getElementById("status");
const $loginSection = document.getElementById("login-section");
const $sessionSection = document.getElementById("session-section");
const $productsSection = document.getElementById("products-section");
const $loginForm = document.getElementById("login-form");
const $email = document.getElementById("email");
const $password = document.getElementById("password");
const $userName = document.getElementById("user-name");
const $userEmail = document.getElementById("user-email");
const $btnLogout = document.getElementById("btn-logout");
const $btnRefresh = document.getElementById("btn-refresh");
const $tbody = document.getElementById("products-body");
const $apiLink = document.getElementById("api-link");

let accessToken = null;
let refreshToken = null;

$apiLink.href = BASE_URL;

// Helpers
function setStatus(msg, type = "info") {
  $status.textContent = msg || "";
  $status.style.borderColor = type === "error" ? "#ef4444" : "#1f2937";
  $status.style.color = type === "error" ? "#ffb4b4" : "#9fb0c0";
}

function showLoggedIn(user) {
  $userName.textContent = user?.full_name || user?.username || "(sin nombre)";
  $userEmail.textContent = user?.email || "";
  $loginSection.classList.add("hidden");
  $sessionSection.classList.remove("hidden");
  $productsSection.classList.remove("hidden");
}

function showLoggedOut() {
  accessToken = null;
  refreshToken = null;
  sessionStorage.clear();
  $loginSection.classList.remove("hidden");
  $sessionSection.classList.add("hidden");
  $productsSection.classList.add("hidden");
  $tbody.innerHTML = "";
}

// If the session still exist, rehidrate/re-connect
(function restoreSession() {
  const stored = sessionStorage.getItem("auth");
  if (stored) {
    try {
      const data = JSON.parse(stored);
      accessToken = data.accessToken;
      refreshToken = data.refreshToken;
      if (accessToken) {
        
        getProfile().then(user => {
          showLoggedIn(user);
          setStatus("Sesion restaurada.");
          fetchProducts();
        }).catch(() => {
          showLoggedOut();
        });
      }
    } catch {}
  }
})();



// ============ API Calls ============
async function login(email, password) {
  const url = `${BASE_URL}${ENDPOINTS.login}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password })
  });

  if (!res.ok) {
    const msg = await safeMessage(res);
    throw new Error(`Error en login (${res.status}): ${msg}`);
  }

  const data = await res.json();
  accessToken = data.access_token;
  refreshToken = data.refresh_token;
  sessionStorage.setItem("auth", JSON.stringify({ accessToken, refreshToken }));

  return data;
}

async function getProfile() {
  const url = `${BASE_URL}${ENDPOINTS.profile}`;
  const res = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${accessToken}`
    }
  });

  if (!res.ok) {
    const msg = await safeMessage(res);
    throw new Error(`Perfil fallo (${res.status}): ${msg}`);
  }

  return res.json();
}

async function fetchProducts() {
  const url = `${BASE_URL}${ENDPOINTS.products}`;
  setStatus("Cagando productos...");

  const res = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${accessToken}`
    }
  });

  if (!res.ok) {
    const msg = await safeMessage(res);
    setStatus(`No se pudieron cargar productos: ${msg}`, "error");
    return;
  }

  const data = await res.json();
  renderProducts(Array.isArray(data) ? data : (data.results || data));
  setStatus(`Productos cargados (${Array.isArray(data) ? data.length : (data.count ?? "n/d")}).`);
}

async function logout() {
  
  try {
    await fetch(`${BASE_URL}/api/users/users/logout/`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(accessToken ? { "Authorization": `Bearer ${accessToken}` } : {})
      },
      body: JSON.stringify({ refresh_token: refreshToken || "" })
    });
  } catch {}

  showLoggedOut();
  setStatus("Sesión cerrada.");
}

async function safeMessage(res) {
  try {
    const t = await res.text();
    try { return JSON.parse(t).detail || t; } catch { return t; }
  } catch { return "Error no conocido"; }
}

// ============ UI Handlers ============
$loginForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  setStatus("Iniciando sesión…");
  const email = $email.value.trim();
  const password = $password.value;

  if (!email || !password) {
    setStatus("Ingresa email y password.", "error");
    return;
  }

  try {
    const auth = await login(email, password);
    const user = auth.user || await getProfile();
    showLoggedIn(user);
    setStatus(`Bienvenido, ${user.full_name || user.username || user.email}.`);
    fetchProducts();
  } catch (err) {
    setStatus(err.message || "No se pudo iniciar sesion.", "error");
  }

});

$btnLogout.addEventListener("click", logout);
$btnRefresh.addEventListener("click", fetchProducts);




function renderProducts(items) {
  $tbody.innerHTML = "";

  // if there's nothing or something happened with the items retrieval
  if (!items || !items.length) {
    $tbody.innerHTML = `<tr><td colspan="5" class="td-empty">Sin productos.</td></tr>`;
    return;
  }

  for (const p of items) {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${esc(p.id)}</td>
      <td>${esc(p.name)}</td>
      <td>${esc(p.sku)}</td>
      <td>${esc(p.price)}</td>
      <td>${esc(p.stock_quantity)}</td>
    `;

    $tbody.appendChild(tr);
  }
}

function esc(v) {
  if (v === null || v === undefined) return "";
  return String(v).replace(/[&<>"']/g, s => ({
    "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"
  }[s]));
}
