/**
 * ENDERSTUDIO - CONTROL CORE v4.0
 * Administrador: endersonsoto06@gmail.com
 * Este script gestiona el acceso administrativo y logs de interacción.
 */

// --- CONFIGURACIÓN DE SEGURIDAD ---
const ADMIN_EMAIL = "endersonsoto06@gmail.com";

// Función para verificar identidad y mostrar panel de subida
function checkAdminAccess() {
    // Usamos localStorage para que solo tengas que loguearte una vez en tu móvil
    let isAdmin = localStorage.getItem("ender_admin_auth");

    if (!isAdmin) {
        let accessEmail = prompt("Acceso Restringido. Introduce el correo del desarrollador:");
        if (accessEmail === ADMIN_EMAIL) {
            localStorage.setItem("ender_admin_auth", "true");
            showAdminTools();
        } else if (accessEmail !== null) {
            alert("Acceso denegado. Credenciales incorrectas.");
        }
    } else {
        showAdminTools();
    }
}

function showAdminTools() {
    const adminPanel = document.getElementById('admin-panel');
    if (adminPanel) {
        adminPanel.style.display = 'block';
        console.log("%c [AUTH]: Modo Administrador Activo", "color: #00d9ff; font-weight: bold;");
    }
}

// --- GESTIÓN DE SUBIDA (GITHUB DIRECT) ---
function uploadPlugin() {
    // Configuración directa a tu repositorio
    const user = "Enderson211";
    const repo = "Ender"; 
    // Esta URL te lleva directo a la interfaz de subida de archivos en la carpeta plugins
    const uploadUrl = `https://github.com/${user}/${repo}/upload/main/plugins`;
    
    console.log("%c [SISTEMA]: Redirigiendo a interfaz de subida...", "color: #ffcc00;");
    window.location.href = uploadUrl;
}

// --- LOGS DE AUDITORÍA (PARA LA CONSOLA) ---
function initLogs() {
    console.log("%c ENDERSTUDIO %c v4.0 ", "background: #00d9ff; color: #000; padding: 2px 5px; font-weight: bold;", "background: #001a2c; color: #00d9ff; padding: 2px 5px;");
    console.log("Estado del sistema: ONLINE");
    console.log("Cargando módulos de seguridad y Webhooks...");
}

// --- EJECUCIÓN INICIAL ---
document.addEventListener('DOMContentLoaded', () => {
    initLogs();
    
    // Verificamos si es el administrador quien entra
    // Nota: Esto se activa al cargar la página
    checkAdminAccess();

    // Listener para los botones de descarga (Solo para loguear en consola)
    const downloadBtns = document.querySelectorAll('.download-btn');
    downloadBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const pluginName = this.getAttribute('href').split('/').pop();
            console.log(`%c [DESCARGA]: El usuario ha solicitado: ${pluginName}`, "color: #00ff00;");
        });
    });
});

/**
 * Nota Técnica:
 * Para cerrar sesión como admin y probar la vista de usuario, 
 * ejecuta 'localStorage.clear()' en la consola del navegador.
 */
